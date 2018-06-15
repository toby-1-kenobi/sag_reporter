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

      user = User.find_by phone: login_params["phone"]
      # check, whether user exists
      unless user
        logger.error "User not found"
        render json: {error: "User not found"}, status: :forbidden
        return
      end
      # check, whether password is correct
      unless user.authenticate login_params["password"]
        logger.error "Password wrong"
        render json: {error: "Password wrong", user: user.id}, status: :unauthorized
        return
      end
      # check, whether user device exists and is registered (= successful login)
      users_device = user.external_devices.find {|d| d.device_id == login_params["device_id"]}
      if users_device && (users_device.registered || user.authenticate_otp(login_params["otp"], drift: 300))
        users_device.update registered: true unless users_device.registered
        if users_device.name != login_params["device_name"]
          users_device.update name: login_params["device_name"]
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
        new_device.device_id = login_params["device_id"]
        new_device.name = login_params["device_name"]
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

  def send_request
    safe_params = [
        :last_sync
    ]
    send_request_params = params.require(:external_device).permit(safe_params)

    tables = [User, GeoState, LanguageProgress, Language, Report, Person, Topic, ProgressMarker,
              Zone, ImpactReport, UploadedFile]
    exclude_attributes = {
        User: %w(password_digest remember_digest otp_secret_key confirm_token reset_password reset_password_token)
    }
    join_tables = {
        User: %w(geo_states spoken_languages),
        GeoState: %w(languages),
        Report: %w(languages observers),
        ImpactReport: %w(progress_markers)
    }
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
    @final_file = Tempfile.new
    render json: {data: "#{@final_file.path}.txt"}, status: :ok
    Thread.new do
      begin
        File.open(@final_file, "w") do |file|
          @sync_time = 5.seconds.ago
          file.write "{\"last_sync\":#{@sync_time.to_i}"
          last_sync = Time.at send_request_params["last_sync"]
          @needed = {:updated_at => last_sync .. @sync_time}
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
          file.write '}'
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
        logger.debug "File writing finished. Size: #{@final_file.size}"
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
        :uploaded_files => [],
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
                                    data: image_data
                                }.to_json)
          else
            errors << {"uploaded_file:#{uploaded_file.id}" => "permission denied"}
          end
        end
        send_message = { UploadedFile: pictures_data }
        send_message.merge!({ errors: errors}) unless errors.size == 0
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
          :is_only_test,
          :UploadedFile => [
              :id,
              :data,
              :old_id
          ],
          :Report => [
              :id,
              :geo_state_id,
              {:language_ids => [:old_id]},
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
              :version,
              :old_id,
              :impact_report => [
                  {:ImpactReport => [
                      :id,
                      :shareable,
                      :translation_impact,
                      :old_id
                  ]}
              ]
          ]
      ]
      receive_request_params = params.require(:external_device).permit(safe_params)

      @errors = []
      @id_changes = {}

      [ImpactReport, Report, UploadedFile].each do |table|
        puts "Params: " + receive_request_params[table.name].to_s + table.name.to_s
        receive_request_params[table.name]&.each do |entry|
          new_entry = build table, entry.to_h
          if receive_request_params["is_only_test"]
            raise new_entry.errors.messages.to_s unless !new_entry || new_entry.valid?
          else
            raise new_entry.errors.messages.to_s unless !new_entry || new_entry.save
          end
        end
      end

      puts "Errors: #{@errors}"
      # Send back all the ID changes (as only the whole entries were saved, the ID has to be retrieved here)
      if receive_request_params["is_only_test"]
        send_message = {}
      else
        send_message = @id_changes
        @id_changes.each{|k,v| v.each{|k2,v2| send_message[k][k2] = v2.id}}
      end
      send_message.merge({error: @errors}) unless @errors.empty?
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

  def build(table, hash)
    old_id = nil
    begin
      if table == Report && hash["reporter_id"] != @external_user && !@external_user.admin
        Report.find(hash["id"]).touch if hash["id"]
        raise "User is not allowed to edit report #{hash["id"]}"
      end
      # Go through all the entries to check, whether it has an ID from another uploaded entry
      hash.each do |k, v|
        if v.class == Array
          v.map! do |element|
            # A hash inside an array means always, that the the ID has to be mapped according to the newly created ID
            # An example would be {..., "observers" => [20, {"old_id" => "Person;100010"}]}
            if element.class == Hash
              table, old_id = element.values.first.split(';')
              @id_changes[table][old_id.to_i]
            else
              element
            end
          end
        elsif v.class == Hash
          intern_table = v.keys.first.constantize rescue nil
          if intern_table && v.values.first.class == Hash
            hash[k] = build intern_table, v.values.first
          end
        end
      end
      if table == UploadedFile
        create_file(hash)
      elsif hash["id"]
        table.update hash["id"], hash
      else
        old_id = hash.delete "old_id"
        new_entry = table.new hash
        @id_changes[table.name] = {old_id => new_entry} if old_id
        new_entry
      end
    rescue => e
      @errors << {"#{table.name}:#{old_id}" => e}
      return nil
    end
  end

  def create_file(values)
    old_id = nil
    begin
      filename = 'external_uploaded_image'
      tempfile = Tempfile.new filename
      tempfile.binmode
      tempfile.write Base64.decode64 values.delete('data')
      tempfile.rewind
      content_type = `file --mime -b #{tempfile.path}`.split(';')[0]
      extension = content_type.match(/gif|jpg|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      values["ref"] = ActionDispatch::Http::UploadedFile
                          .new({
                                   tempfile: tempfile,
                                   type: content_type,
                                   filename: filename
                               })
      table = UploadedFile
      if values["id"]
        table.update values["id"], values
      else
        old_id = values.delete "old_id"
        new_entry = table.new values
        raise new_entry.errors.messages.to_s unless uploaded_file.save
        @id_changes[table.name] = {old_id => new_entry.id} if old_id
        new_entry
      end
    rescue => e
      @errors << {"uploaded_file:#{old_id}" => e}
      return nil
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def save_data_in_file(send_message)
    File.open(@all_data, "w") do |final_file|
      final_file.write "{"
      send_message.each_with_index do |pair, index|
        category, file = pair
        file.close
        file.open
        final_file.write ', ' unless index == 0
        final_file.write "\"#{category}\": ["
        final_file.write file.read
        final_file.write ']'
        file.close
        file.unlink
      end
      final_file.write '}'
    end
    @all_data.close
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

  def create_database_key(user)
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
      if user.updated_at.to_i == payload['iat']
        user if users_device
      else
        users_device.update registered: false if users_device&.registered
        false
      end
    rescue => e
      logger.error e
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
