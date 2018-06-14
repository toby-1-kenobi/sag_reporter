class ExternalDeviceController < ApplicationController

  include JwtConcern
  include ParamsHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_external, except: [:test_server, :login, :send_otp, :get_database_key]

  def test_server
    head :ok
  end

  def login
    begin
      safe_params = [
          :phone,
          :password,
          :device_id,
          :device_name,
          :otp
      ]
      login_params = params.require(:external_device).permit(safe_params)

      user = User.find_by phone: login_params[:phone]
      # check, whether user exists
      unless user
        logger.error "User not found"
        render json: {error: "User not found"}, status: :forbidden
        return
      end
      # check, whether password is correct
      unless user.authenticate login_params[:password]
        logger.error "Password wrong"
        render json: {error: "Password wrong"}, status: :unauthorized
        return
      end
      # check, whether user device exists and is registered (= succesful login)
      users_device = user.external_devices.find {|d| d.device_id == login_params[:device_id]}
      if users_device && (users_device.registered || user.authenticate_otp(login_params[:otp], drift: 300))
        users_device.update registered: true unless users_device.registered
        if users_device.name != login_params[:device_name]
          users_device.update name: login_params[:device_name]
        end
        payload = {sub: user.id, iat: user.updated_at.to_i, iss: users_device.device_id}
        send_message = {
            user: user.id,
            status: "success",
            jwt: encode_jwt(payload),
            database_key: create_database_key(user),
            now: Time.now.to_i
        }
        logger.debug send_message
        render json: send_message, status: :ok
        return
      end
      # create the (in future unregistered) device, if it doesn't exist
      unless users_device
        new_device = ExternalDevice.new
        new_device.device_id = login_params[:device_id]
        new_device.name = login_params[:device_name]
        new_device.user = user
        raise new_device.errors.messages.to_s unless new_device.save
      end
      logger.error "Device not registered"
      render json: {user: user.id, status: "OTP", error: "Device not registered, register with OTP"}, status: :created
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def send_otp
    safe_params = [
        :user_phone,
        :device_id,
        :target
    ]
    send_otp_params = params.require(:external_device).permit(safe_params)

    user = User.find_by_phone send_otp_params['user_phone']
    users_device = ExternalDevice.find_by user_id: user&.id, device_id: send_otp_params['device_id']
    unless users_device && !users_device.registered
      render json: {error: 'Device not found'}, status: :forbidden
      return
    end
    case send_otp_params['target']
      when 'phone'
        success = send_otp_on_phone("+91#{user.phone}", user.otp_code)
      when 'email'
        success = send_otp_via_mail(user, user.otp_code)
      else
        success = false
    end
    render json: {status: "OTP code sending success: #{success}"}, status: :ok
  end

  def get_database_key
    begin
      safe_params = [
          :user_id,
          :device_id
      ]
      get_database_key_params = params.require(:external_device).permit(safe_params)

      # Check, whether user exists and device is registered
      users_device = ExternalDevice.find_by device_id: get_database_key_params['device_id'], user_id: get_database_key_params['user_id']
      unless users_device&.registered?
        logger.error "Device not found / registered"
        if users_device
          render json: {error: "Device not registered"}, status: :unauthorized
        else
          render json: {error: "Device not found"}, status: :forbidden
        end
        return
      end
      user = User.find_by_id get_database_key_params['user_id']
      database_key = (user.created_at.to_f * 1000000).to_i
      logger.debug 'database key send'
      render json: {key: database_key}, status: :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def additional_tables(entry)
    case entry.class
      when Report
        {project_languages: entry.state_languages.in_project.map(&:language)}
      when ProgressMarker
        {description: progress_marker.description_for(@external_user)}
      else
        {}
    end
  end
  def send_request
    safe_params = [
        :updated_at
    ]
    send_request_params = params.require(:external_device).permit(safe_params)

    tables = [User, GeoState, LanguageProgress, Language, Report, Person, Topic, ProgressMarker, Zone, ImpactReport]
    exclude_attributes = {
        User: %w(password_digest remember_digest otp_secret_key confirm_token reset_password reset_password_token)
    }
    join_tables = {
        User: %w(geo_states spoken_languages),
        GeoState: %w(languages),
        Report: %w(languages progress_markers observers pictures)
    }
    @final_file = Tempfile.new
    render json: {data: "#{@final_file.path}.txt"}, status: :ok
    Thread.new do
      begin
        File.open(@final_file, "w") do |file|
          @sync_time = 5.seconds.ago
          file.write "{\"updated_at\":#{@sync_time.to_i}"
          last_updated_at = Time.at send_request_params[:updated_at]
          @needed = {:updated_at => last_updated_at .. @sync_time}
          tables.each do |table|
            table_name = table.name.to_sym
            file.write(',')
            file.write "\"#{table_name}\":["
            table.where(@needed).includes(join_tables[table_name]).each_with_index do |entry, index|
              entry_data = entry.attributes.except("created_at", "updated_at", *exclude_attributes[table_name])
              join_tables[table_name]&.each do |join_table|
                entry_data.merge!({join_table => entry.send(join_table.singularize.foreign_key.pluralize)})
              end
              entry_data.merge! additional_tables(entry)
              file.write(',') if index != 0
              file.write entry_data.to_json
            end
            file.write ']'
            ActiveRecord::Base.connection.query_cache.clear
          end
        end
      rescue => e
        send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
        logger.error send_message
        file_path = @final_file.path
        @final_file.delete
        @final_file = File.new file_path, "w"
        @final_file.write send_message
      ensure
        @final_file.close
        File.rename(@final_file, "#{@final_file.path}.txt")
        ActiveRecord::Base.connection.close
      end
    end
  end

  def get_file
    begin
      safe_params = [
          :file_path
      ]
      get_file_params = params.require(:external_device).permit(safe_params)

      file_path = get_file_params['file_path']
      until File.exists?(file_path)
        sleep 1
      end
      send_file file_path, status: :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def get_uploaded_file
    safe_params = [
        :uploaded_files => [:id],
    ]
    get_uploaded_file_params = params.require(:external_device).permit(safe_params)

    @all_data = Tempfile.new
    render json: {data: @all_data.path}, status: :ok
    Thread.new do
      begin
        uploaded_file_ids = get_uploaded_file_params['uploaded_files'].map {|key, _| key.to_i}
        pictures_data, errors = Array.new(2) {Tempfile.new}
        UploadedFile.includes(:report).find(uploaded_file_ids).each do |uploaded_file|
          image_data = if uploaded_file&.ref.file.exists?
                         Base64.encode64(uploaded_file.ref.read)
                       else
                         ""
                       end
          if external_user.trusted? || uploaded_file.report.reporter == external_user
            pictures_data.write(', ') unless pictures_data.length == 0
            pictures_data.write({
                                    id: uploaded_file.id,
                                    data: image_data,
                                    updated_at: uploaded_file.updated_at.to_i
                                }.to_json)
          else
            errors << {"uploaded_file_#{uploaded_file.id}" => "permission denied"}
          end
        end
        send_message = {
            errors: errors,
            pictures_data: pictures_data
        }
        save_data_in_file send_message
      rescue => e
        send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
        logger.error send_message
        @all_data.write send_message
      ensure
        [@all_data, pictures_data, errors].each &:close
        [pictures_data, errors].each &:delete
      end
    end
  end

  def receive_request
    begin
      safe_params = [
          :uploaded_files => [
              :status,
              :data
          ],
          :reports => [
              :status,
              :geo_state_id,
              {:language_ids => []},
              :report_date,
              :translation_impact,
              :significant,
              {:picture_ids => []},
              :content,
              :reporter_id,
              :impact_report,
              {:progress_marker_ids => []},
              {:observer_ids => []},
              :client,
              :version
          ]
      ]
      receive_request_params = params.require(:external_device).permit(safe_params)

      @uploaded_file_feedbacks, @report_feedbacks, @errors = Array.new(3) {Array.new}
      receive_request_params[:reports].each do |report_id, report_params|
        receive_report report_id, report_params, receive_request_params[:uploaded_files]
      end
      receive_request_params[:uploaded_files].each do |uploaded_file_id, uploaded_file_params|
        receive_uploaded_file uploaded_file_id, uploaded_file_params
      end
      send_message = {
          error: @errors,
          reports: @report_feedbacks,
          uploaded_files: @uploaded_file_feedbacks
      }
      logger.debug send_message
      render json: send_message, status: :created
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  private

  # receive_request methods:

  def receive_uploaded_file(uploaded_file_id, uploaded_file_data)
    logger.debug "Save file: #{uploaded_file_id}"
    status = uploaded_file_data.delete 'status'
    if status == 'delete'
      UploadedFile.delete uploaded_file_id
      return nil
    end
    if status != 'new'
      @errors << {"uploaded_file_#{uploaded_file_id}" => "Unknown status: #{status}"}
      return nil
    end
    # convert image-string to image-file
    begin
      filename = 'external_uploaded_image'
      tempfile = Tempfile.new filename
      tempfile.binmode
      tempfile.write Base64.decode64 uploaded_file_data.delete('data')
      tempfile.rewind
      content_type = `file --mime -b #{tempfile.path}`.split(';')[0]
      extension = content_type.match(/gif|jpg|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      uploaded_file_data[:ref] = ActionDispatch::Http::UploadedFile.new({
                                                                            tempfile: tempfile,
                                                                            type: content_type,
                                                                            filename: filename
                                                                        })
      uploaded_file = UploadedFile.new(uploaded_file_data)
      raise uploaded_file.errors.messages.to_s unless uploaded_file.save
      uploaded_file.touch
      @uploaded_file_feedbacks << {
          id: uploaded_file_id,
          updated_at: uploaded_file.updated_at.to_i,
          new_id: uploaded_file.id,
          last_changed: 'uploaded'
      }
      return uploaded_file.id
    rescue => e
      @errors << {"uploaded_file_#{uploaded_file_id}" => e}
      return nil
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def receive_report(report_id, report_data, uploaded_files_data)
    logger.debug "Save report: #{report_id}"
    return if report_data.nil?
    impact_report = report_data.delete 'impact_report'
    status = report_data.delete 'status'
    report_data['report_date'] &&= Date.parse report_data['report_date']
    report_data['picture_ids'] && report_data['picture_ids'].map! do |picture_id|
      picture_id = picture_id.to_i
      picture_data = uploaded_files_data.delete picture_id.to_s
      if picture_data
        receive_uploaded_file picture_id, picture_data
      else
        picture_id
      end
    end
    impact_report_data = Hash.new
    impact_report_data['progress_marker_ids'] = report_data.delete 'progress_marker_ids'
    impact_report_data['translation_impact'] = report_data.delete 'translation_impact'
    supervisor_mail = report_data['significant']
    report_data['significant'] &&= true
    if status == 'old'
      report = Report.find_by_id report_id
      unless report
        @errors << {"report_#{report_id}" => "Couldn't find report"}
        return
      end
      unless external_user.admin? || external_user.id == report.reporter_id
        @errors << {"report_#{report_id}" => "No right to edit report"}
        return
      end
      report_data['picture_ids'] ||= []
      (report.picture_ids - report_data['picture_ids']).each do |deleted_picture_id|
        receive_uploaded_file deleted_picture_id, 'status' => 'delete'
      end
      if report.update(report_data) && report.impact_report.update(impact_report_data)
        report.touch
        @report_feedbacks << {
            id: report_id,
            updated_at: report.updated_at.to_i,
            last_changed: 'uploaded'
        }
      else
        @errors << {"report_#{report_id}" => report.errors.messages.to_s}
      end
    elsif status == 'new'
      report = Report.new report_data
      report.impact_report = ImpactReport.new(impact_report_data) if impact_report
      if supervisor_mail
        if send_mail(report, supervisor_mail)
          mail_info = {mail: "send successful"}
        else
          mail_info = {mail: "send not successful"}
        end
      else
        mail_info = {}
      end
      if report.save
        @report_feedbacks << {
            id: report_id,
            updated_at: report.updated_at.to_i,
            new_id: report.id,
            last_changed: 'uploaded'
        }.merge(mail_info)
      else
        @errors << {"report_#{report_id}" => report.errors.messages.to_s}
      end
    else
      @errors << {"report_#{report_id}" => "Unknown status: #{status}"}
    end
  end

  def send_mail(report, mail)
    # make sure TLS gets used for delivering this email
    if SendGridV3.enforce_tls
      recipient = User.find_by_email mail
      recipient ||= mail
      delivery_success = false
      begin
        if recipient
          logger.debug "sending report to: #{recipient}"
          UserMailer.user_report(recipient, report).deliver_now
          delivery_success = true
        end
      rescue => e
        @errors << 'Failed to send the report to the supervisor'
        logger.error e.message
      end
      if delivery_success
        # also send it to the reporter
        UserMailer.user_report(report.reporter, report).deliver_now
        return true
      end
    else
      @errors << 'Could not ensure email encryption so didn\'t send the report to the supervisor'
      logger.error 'Could not enforce TLS with SendGrid'
    end
    false
  end

  def send_otp_on_phone(phone_number, otp_code)
    begin
      logger.debug "sending otp to phone: #{phone_number}, otp: #{otp_code}"
      wait_ticket = BcsSms.send_otp(phone_number, otp_code)
      logger.debug "waiting #{wait_ticket}"
      wait_ticket
    rescue => e
      logger.error "couldn't send OTP to phone: #{e.message}"
      false
    end
  end

  def send_otp_via_mail(user, otp_code)
    # don't need to enforce TLS for sending the login code.
    # if we can't turn off enforce_tls then send the code anyway
    unless SendGridV3.dont_enforce_tls
      begin
        if SendGridV3.enforce_tls?
          logger.error 'could not turn off enforce TLS with SendGrid for sending login code'
        end
      rescue SocketError => e
        logger.error 'could not turn of enforce TLS and could not determine if it is already off.'
        logger.error e.message
      end
    end
    if user.email.present? && user.email_confirmed?
      logger.debug "sending otp to email: #{user.email}, otp: #{otp_code}"
      UserMailer.user_otp_code(user, otp_code).deliver_now
      true
    else
      false
    end
  end

  # other helpful methods

  def create_database_key user
    (user.created_at.to_f * 1000000).to_i
  end

  def authenticate_external
    render json: { error: "JWT invalid" }, status: :unauthorized unless external_user
  end

  def external_user
    @external_user ||= begin
      token = request.headers['Authorization'].split.last
      payload = decode_jwt(token)
      user = User.find_by_id payload['sub']
      users_device = ExternalDevice.find_by device_id: payload['iss'], user_id: user.id
      puts "#{user.updated_at.to_i} #{payload['iat']}"
      if user.updated_at.to_i == payload['iat']
        user if users_device
      else
        users_device.update registered: false if users_device&.registered
        false
      end
    rescue => e
      puts e
      nil
    end
  end

end
# for easily getting all attributes:
# Language.new.attributes.except("created_at","updated_at").keys.each{|k|puts "          #{k}: xxx.#{k},"}.nil?

# hm=Person.reflect_on_all_associations(:has_many).map{|r|r.name}
# hm2=hm.map{|h|h.to_s.singularize + "_ids"}
# Person.includes(hm).map{|p| hm2.map{|h|[h,p.send(h)]}.to_h.merge(p.attributes.except("created_at", "updated_at"))}

# Language.reflect_on_all_associations(:has_many).map{|a|[a.name,a.options[:through],a.options[:source]]}
# => [[:geo_states, :state_languages, nil],...]
# Language.includes(a.options[:through]).map {|l|l.send(a.options[:through]).map &a.options[:source] || a.name}

# def r t;t.reflect_on_all_associations(:has_many).map {|a|puts [a.name.to_s.singularize.to_sym, a.options[:through], a.options[:source]].to_s};t.reflect_on_all_associations(:has_and_belongs_to_many).map {|a|puts [a.name.to_s.singularize.to_sym, a.options[:through], a.options[:source]].to_s}.nil?; end
