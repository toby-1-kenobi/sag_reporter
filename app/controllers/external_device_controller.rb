class ExternalDeviceController < ApplicationController

  include ParamsHelper
  include ExternalDeviceHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_external, except: [:test_server, :login, :send_otp, :get_database_key]

  def test_server
    head :ok
  end

  def login
    begin
      full_params = login_params
      user = User.find_by phone: full_params[:phone]
      # check, whether user exists
      unless user
        logger.error "User not found"
        render json: {error: "User not found"}, status: :forbidden
        return
      end
      # check, whether password is correct
      unless user.authenticate full_params[:password]
        logger.error "Password wrong"
        render json: {error: "Password wrong"}, status: :unauthorized
        return
      end
      # check, whether user device exists and is registered (= succesful login)
      users_device = user.external_devices.find {|d| d.device_id == full_params[:device_id]}
      if users_device && (users_device.registered || user.authenticate_otp(full_params[:otp], drift: 300))
        users_device.update registered: true unless users_device.registered
        if users_device.name != full_params[:device_name]
          users_device.update name: full_params[:device_name]
        end
        send_message = {
            user: user.id,
            status: "success",
            jwt: create_jwt(user, users_device.device_id),
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
        new_device.device_id = full_params[:device_id]
        new_device.name = full_params[:device_name]
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
    full_params = send_otp_params
    user = User.find_by_phone full_params['user_phone']
    users_device = ExternalDevice.find_by user_id: user&.id, device_id: full_params['device_id']
    unless users_device && !users_device.registered
      render json: {error: 'Device not found'}, status: :forbidden
      return
    end
    case full_params['target']
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
      full_params = get_database_key_params
      # Check, whether user exists and device is registered
      users_device = ExternalDevice.find_by device_id: full_params['device_id'], user_id: full_params['user_id']
      unless users_device&.registered?
        logger.error "Device not found / registered"
        if users_device
          render json: {error: "Device not registered"}, status: :unauthorized
        else
          render json: {error: "Device not found"}, status: :forbidden
        end
        return
      end
      user = User.find_by_id full_params['user_id']
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
    @all_data = Tempfile.new
    render json: {data: @all_data.path}, status: :ok
    Thread.new do
      begin
        @sync_time = 5.seconds.ago
        last_updated_at = Time.at send_request_params[:updated_at]
        @needed = {:updated_at => last_updated_at .. @sync_time}
        @users, @geo_states, @languages, @reports,
            @people, @topics, @progress_markers, @zones, @errors = Array.new(10) {Tempfile.new}
        @user_ids, @geo_state_ids, @language_ids, @report_ids,
            @person_ids, @topic_ids, @progress_marker_ids, @zone_ids = Array.new(9) {Set.new}
        @all_updated_at = {}
        begin
          send_external_user
          send_language external_user.mother_tongue
          external_user.spoken_languages.where(@needed).each {|language| send_language language}
          send_language external_user.interface_language
          external_user.championed_languages.where(@needed).each {|language| send_language language}
          ActiveRecord::Base.connection.query_cache.clear
        end
        begin
          User.where(@needed).select(:id, :name, :mother_tongue_id, :updated_at).collect
              .each {|user| send_user_name(user) if user.id != external_user.id} if external_user.trusted?
          ActiveRecord::Base.connection.query_cache.clear
        end
        begin
          if external_user.national?
            user_geo_states = GeoState.all
          else
            user_geo_states = external_user.geo_states
          end
          user_geo_states.where(@needed).includes(:languages, :zone, :state_languages).each do |geo_state|
            send_geo_state geo_state
            send_zone geo_state.zone
            geo_state.languages.each {|language| send_language language}
            ActiveRecord::Base.connection.query_cache.clear
          end
        end
        begin
          Person.where(@needed).each {|person| send_person person} if external_user.trusted?
          Topic.where(@needed).each {|topic| send_topic topic unless topic.hide_for?(external_user)}
          ProgressMarker.where(@needed).each {|progress_marker| send_progress_marker(progress_marker) if progress_marker.number}
          ActiveRecord::Base.connection.query_cache.clear
        end
        begin
          Report.where(@needed).includes(:languages, :observers, :pictures, :impact_report => [:progress_markers], :geo_state => [:languages])
              .order(:report_date).reverse_order.user_limited(external_user).each do |report|
            send_report report
            send_geo_state report.geo_state
            report.languages.each {|language| send_language language}
          end
          ActiveRecord::Base.connection.query_cache.clear
        end
        send_message = {
            errors: @errors,
            users: @users,
            geo_states: @geo_states,
            zones: @zones,
            languages: @languages,
            people: @people,
            topics: @topics,
            progress_markers: @progress_markers,
            reports: @reports
        }
        save_data_in_file send_message
      rescue => e
        send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
        logger.error send_message
        @all_data.write send_message
      ensure
        [@all_data, @users, @geo_states, @languages, @reports,
         @people, @topics, @progress_markers, @errors].each &:close
        [@users, @geo_states, @languages, @reports,
         @people, @topics, @progress_markers, @errors].each &:delete
        ActiveRecord::Base.connection.close
      end
    end
  end

  def get_file
    begin
      file = File.new get_file_params['file_path']
      while file.size == 0
        sleep 1
      end
      send_file get_file_params['file_path'], status: :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def get_uploaded_file
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
      @uploaded_file_feedbacks, @report_feedbacks, @errors = Array.new(3) {Array.new}
      full_params = receive_request_params
      full_params[:reports].each do |report_id, report_params|
        receive_report report_id, report_params, full_params[:uploaded_files]
      end
      full_params[:uploaded_files].each do |uploaded_file_id, uploaded_file_params|
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

  def send_otp_params
    safe_params = [
        :user_phone,
        :device_id,
        :target
    ]
    params.require(:external_device).permit(safe_params)
  end

  def login_params
    safe_params = [
        :phone,
        :password,
        :device_id,
        :device_name,
        :otp
    ]
    params.require(:external_device).permit(safe_params)
  end

  def get_database_key_params
    safe_params = [
        :user_id,
        :device_id
    ]
    params.require(:external_device).permit(safe_params)
  end

  def send_request_params
    safe_params = [
        :updated_at
    ]
    params.require(:external_device).permit(safe_params)
  end

  def get_file_params
    safe_params = [
        :file_path
    ]
    params.require(:external_device).permit(safe_params)
  end

  def get_uploaded_file_params
    safe_params = [
        :uploaded_files => [:id],
    ]
    params.require(:external_device).permit(safe_params)
  end

  def receive_request_params
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
    params.require(:external_device).permit(safe_params)
  end

  # send_request methods

  def send_external_user
    begin
      if check_send_data(@users, external_user, @all_updated_at[:users])
        @users.write({
                         id: external_user.id,
                         name: external_user.name,
                         phone: external_user.phone,
                         mother_tongue_id: external_user.mother_tongue_id,
                         interface_language_id: external_user.interface_language_id,
                         email: external_user.email,
                         email_confirmed: external_user.email_confirmed,
                         trusted: external_user.trusted,
                         national: external_user.national,
                         admin: external_user.admin,
                         national_curator: external_user.national_curator,
                         role_description: external_user.role_description,
                         curator_prompted: external_user.curator_prompted.to_i,

                         geo_state_ids: external_user.geo_state_ids,
                         spoken_language_ids: external_user.spoken_language_ids,
                         updated_at: external_user.updated_at.to_i,
                         last_changed: 'online'
                     }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_user_name(user)
    begin
      if @user_ids.add?(user.id) && check_send_data(@users, user, @all_updated_at[:users])
        @users.write({
                         id: user.id,
                         name: user.name,
                         mother_tongue_id: user.mother_tongue_id,

                         updated_at: user.updated_at.to_i,
                         last_changed: 'online'
                     }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_geo_state(geo_state)
    begin
      if @geo_state_ids.add?(geo_state.id) && check_send_data(@geo_states, geo_state, @all_updated_at[:geo_states])
        project_language_ids = geo_state.state_languages.select(&:project).map &:language_id
        @geo_states.write({
                              id: geo_state.id,
                              name: geo_state.name,
                              zone_id: geo_state.zone_id,

                              language_ids: geo_state.language_ids,
                              project_language_ids: project_language_ids,
                              updated_at: geo_state.updated_at.to_i,
                              last_changed: 'online'
                          }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_zone(zone)
    begin
      if @zone_ids.add?(zone.id) && check_send_data(@zones, zone, @all_updated_at[:zones])
        @zones.write({
                         id: zone.id,
                         name: zone.name,
                         pm_description_type: Zone.pm_description_types[zone.pm_description_type],

                         updated_at: zone.updated_at.to_i,
                         last_changed: 'online'
                     }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_language(language)
    begin
      if language && @language_ids.add?(language.id) && check_send_data(@languages, language, @all_updated_at[:languages])
        @languages.write({
                             id: language.id,
                             name: language.name,
                             description: language.description,
                             lwc: language.lwc,
                             colour: language.colour,
                             iso: language.iso,
                             family_id: language.family_id,
                             population: language.population,
                             pop_source_id: language.pop_source_id,
                             location: language.location,
                             number_of_translations: language.number_of_translations,
                             cluster_id: language.cluster_id,
                             info: language.info,
                             translation_info: language.translation_info,
                             translation_need: Language.translation_needs[language.translation_need],
                             translation_progress: Language.translation_progresses[language.translation_progress],
                             locale_tag: language.locale_tag,
                             population_all_countries: language.population_all_countries,
                             population_concentration: language.population_concentration,
                             age_distribution: language.age_distribution,
                             village_size: language.village_size,
                             mixed_marriages: language.mixed_marriages,
                             clans: language.clans,
                             castes: language.castes,
                             genetic_classification: language.genetic_classification,
                             location_access: language.location_access,
                             travel: language.travel,
                             ethnic_groups_in_area: language.ethnic_groups_in_area,
                             religion: language.religion,
                             believers: language.believers,
                             local_fellowship: language.local_fellowship,
                             literate_believers: language.literate_believers,
                             related_languages: language.related_languages,
                             subgroups: language.subgroups,
                             lexical_similarity: language.lexical_similarity,
                             attitude: language.attitude,
                             bible_first_published: language.bible_first_published,
                             bible_last_published: language.bible_last_published,
                             nt_first_published: language.nt_first_published,
                             nt_last_published: language.nt_last_published,
                             portions_first_published: language.portions_first_published,
                             portions_last_published: language.portions_last_published,
                             selections_published: language.selections_published,
                             nt_out_of_print: language.nt_out_of_print,
                             tr_committee_established: language.tr_committee_established,
                             translation_consultants: language.translation_consultants,
                             translation_interest: language.translation_interest,
                             translator_background: language.translator_background,
                             translation_local_support: language.translation_local_support,
                             mt_literacy: language.mt_literacy,
                             l2_literacy: language.l2_literacy,
                             script: language.script,
                             attitude_to_lang_dev: language.attitude_to_lang_dev,
                             mt_literacy_programs: language.mt_literacy_programs,
                             poetry_print: language.poetry_print,
                             oral_traditions_print: language.oral_traditions_print,
                             champion_id: language.champion_id,
                             champion_prompted: language.champion_prompted.to_i,

                             updated_at: language.updated_at.to_i,
                             last_changed: 'online'
                         }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_person(person)
    begin
      if @person_ids.add?(person.id) && check_send_data(@people, person, @all_updated_at[:people])
        @people.write({
                          id: person.id,
                          name: person.name,
                          description: person.description,
                          phone: person.phone,
                          address: person.address,
                          intern: person.intern,
                          facilitator: person.facilitator,
                          pastor: person.pastor,
                          language_id: person.language_id,
                          user_id: person.user_id,
                          geo_state_id: person.geo_state_id,

                          updated_at: person.updated_at.to_i,
                          last_changed: 'online'
                      }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_topic(topic)
    begin
      if @topic_ids.add?(topic.id) && check_send_data(@topics, topic, @all_updated_at[:topics])
        @topics.write({
                          id: topic.id,
                          name: topic.name,
                          description: topic.description,
                          colour: topic.colour,
                          number: topic.number,

                          updated_at: topic.updated_at.to_i,
                          last_changed: 'online'
                      }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_progress_marker(progress_marker)
    begin
      if @progress_marker_ids.add?(progress_marker.id) && check_send_data(@progress_markers, progress_marker, @all_updated_at[:progress_markers])
        @progress_markers.write({
                                    id: progress_marker.id,
                                    name: progress_marker.name,
                                    topic_id: progress_marker.topic_id,
                                    weight: progress_marker.weight,
                                    status: ProgressMarker.statuses[progress_marker.status],
                                    number: progress_marker.number,

                                    description: progress_marker.description_for(external_user),
                                    updated_at: progress_marker.updated_at.to_i,
                                    last_changed: 'online'
                                }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def send_report(report)
    begin
      if @report_ids.add?(report.id) && check_send_data(@reports, report, @all_updated_at[:reports])
        @reports.write({
                           id: report.id,
                           reporter_id: report.reporter_id,
                           content: report.content,
                           mt_society: report.mt_society,
                           mt_church: report.mt_church,
                           needs_society: report.needs_society,
                           needs_church: report.needs_church,
                           event_id: report.event_id,
                           geo_state_id: report.geo_state_id,
                           status: Report.statuses[report.status],
                           sub_district_id: report.sub_district_id,
                           location: report.location,
                           client: report.client,
                           version: report.version,
                           significant: report.significant,

                           report_date: report.report_date.strftime("%Y-%m-%d"),
                           planning_report: !!report.planning_report_id,
                           impact_report: !!report.impact_report_id,
                           challenge_report: !!report.challenge_report_id,
                           progress_marker_ids: report.impact_report&.progress_marker_ids,
                           shareable: report.impact_report&.shareable,
                           translation_impact: report.impact_report&.translation_impact,
                           picture_ids: report.picture_ids,
                           language_ids: report.language_ids,
                           observer_ids: report.observer_ids,
                           updated_at: report.updated_at.to_i,
                           last_changed: 'online'
                       }.to_json)
      end
    rescue => e
      error_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      @errors.write error_message
    end
  end

  def check_send_data(file, object, send_params)
    if @needed[:updated_at].cover? object&.updated_at
      file.write(', ') unless file.length == 0
      true
    end
  end

  def save_data_in_file(send_message)
    File.open(@all_data, "w") do |final_file|
      final_file.write "{\"updated_at\":#{@sync_time.to_i}"
      first_entry = true
      send_message.each do |category, file|
        file.close
        next if file.length.to_i == 0
        file.open
        final_file.write ', '
        final_file.write "\"#{category}\": ["
        final_file.write file.read
        final_file.write ']'
        file.close
        file.unlink
        first_entry &= false
      end
      final_file.write '}'
    end
    @all_data.close
  end

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
end
# for easily getting all attributes:
# Language.new.attributes.except("created_at","updated_at").keys.each{|k|puts "          #{k}: xxx.#{k},"}.nil?
