class ExternalDeviceController < ApplicationController

  include ParamsHelper
  include ExternalDeviceHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_external, except: [:test_server, :login, :get_database_key]
  
  def test_server
    head :ok
  end
  
  def login
    begin
      full_params = login_params
      user = User.find_by phone: full_params[:phone]
      # check, whether user exists
      unless user
        puts "User not found"
        render json: { error: "User not found" }, status: :unauthorized
        return
      end
      # check, whether password is correct
      if !user.authenticate full_params[:password]
        puts "Password wrong"
        render json: { error: "Password wrong" }, status: :unauthorized
        return
      end
      # check, whether user device exists and is registered (= succesful login)
      users_device = user.external_devices.find{|d| d.device_id == full_params[:device_id]}
      if users_device && users_device.registered
        unless users_device.name == full_params[:device_name]
          ExternalDevice.update users_device.id, name: full_params[:device_name]
        end
        send_message = {
            user: user.id,
            jwt: create_jwt(user, users_device.device_id),
            database_key: create_database_key(user),
            now: Time.now.to_i
        }
        puts send_message
        render json: send_message, status: :created
        return
      end
      # create the (in future unregistered) device, if it doesn't exist
      unless users_device
        new_device = ExternalDevice.new
        new_device.device_id = full_params[:device_id]
        new_device.name = full_params[:device_name]
        new_device.user = user
        new_device.registered = true # Remove this, if manual registration is implemented
        raise new_device.errors.messages.to_s unless new_device.save
        send_message = {
            user: user.id,
            jwt: create_jwt(user, new_device.device_id),
            database_key: create_database_key(user),
            now: Time.now.to_i
        }
        puts send_message
        render json: send_message, status: :created # Remove this, if manual registration is implemented
        return # Remove this, if manual registration is implemented
      end
      puts "Device not registered"
      render json: { user: user.id, error: "Device not registered" }, status: :unauthorized
    rescue => e
      send_message = { error: e.to_s, where: e.backtrace.to_s }
      puts send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def get_database_key
    begin
      full_params = get_database_key_params
      # Check, whether user exists and device is registered
      user = User.find_by_id(full_params['user_id'])
      users_device = user && user.external_devices.find{|d| d.device_id == full_params[:device_id]}
      unless user && users_device && users_device.registered?
        puts "Device not registered"
        render json: { error: "Device not registered" }, status: :unauthorized
        return
      end
      database_key = (user.created_at.to_f * 1000000).to_i
      puts database_key
      render json: { key: database_key }, status: :ok
    rescue => e
      send_message = { error: e.to_s, where: e.backtrace.to_s }
      puts send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def send_request
    begin
      @users, @geo_states, @languages, @reports, @uploaded_files,
      @people, @topics, @progress_markers = Array.new(8) {Tempfile.new}
      @user_ids, @geo_state_ids, @language_ids, @report_ids, @uploaded_file_ids,
      @person_ids, @topic_ids, @progress_marker_ids = Array.new(8) {Set.new}
      @all_updated_at = send_request_params
      send_external_user
      send_language external_user.mother_tongue
      external_user.spoken_languages.each{|language| send_language language}
      send_language external_user.interface_language
#      external_user.championed_languages.each{|language| send_language language}
      User.all.each{|user| send_user_name(user) if user != external_user}
      if external_user.national?
        user_geo_states = GeoState.all
      else
        user_geo_states = external_user.geo_states
      end
      user_geo_states.includes(:languages).each do |geo_state|
        send_geo_state geo_state
        geo_state.languages.each{|language| send_language language}
      end
      Person.all.each{|person| send_person person}
      Topic.all.each{|topic| send_topic topic unless topic.hide_for?(external_user)}
      ProgressMarker.all.each{|progress_marker| send_progress_marker(progress_marker) if progress_marker.number}
      Report.includes(:languages, :observers, :pictures, :impact_report => [:progress_markers], :geo_state => [:languages])
          .user_limited(external_user).each do |report|
        if (send_report(report))
          report.pictures.each{|picture| send_uploaded_file picture}
        end
        send_geo_state report.geo_state
        report.languages.each{|language| send_language language}
      end
      send_message = {
          users: @users,
          geo_states: @geo_states,
          languages: @languages,
          people: @people,
          topics: @topics,
          progress_markers: @progress_markers,
          reports: @reports,
          uploaded_files: @uploaded_files
      }
      puts send_message
      send_hash_file send_message
    rescue => e
      send_message = { error: e.to_s, where: e.backtrace.to_s }
      puts send_message
      render json: send_message, status: :internal_server_error
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
      puts send_message
      render json: send_message, status: :ok
    rescue => e
      send_message = { error: e.to_s, where: e.backtrace.to_s }
      puts send_message
      render json: send_message, status: :internal_server_error
    end
  end

  private

  def login_params
    safe_params = [
      :phone,
      :password,
      :device_id,
      :device_name
    ]
    permitted = params.require(:external_device).permit(safe_params)
  end

  def get_database_key_params
    safe_params = [
      :user_id,
      :device_id
    ]
    permitted = params.require(:external_device).permit(safe_params)
  end

  def send_request_params
    safe_params = [
      :users => [:updated_at],
      :languages => [:updated_at],
      :geo_states => [:updated_at],
      :topics => [:updated_at],
      :progress_markers => [:updated_at],
      :reports => [:updated_at],
      :uploaded_files => [:updated_at],
      :people => [:updated_at]
    ]
    permitted = params.require(:external_device).permit(safe_params)
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
    permitted = params.require(:external_device).permit(safe_params)
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

            geo_state_ids: external_user.geo_state_ids,
            spoken_language_ids: external_user.spoken_language_ids,
  #          championed_language_ids: external_user.championed_language_ids,
            updated_at: external_user.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_user_name user
    begin
      if @user_ids.add?(user.id) && check_send_data(@users, user, @all_updated_at[:users])
        @users.write({
            id: user.id,
            name: user.name,
            updated_at: user.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_geo_state geo_state
    begin
      if @geo_state_ids.add?(geo_state.id) && check_send_data(@geo_states, geo_state, @all_updated_at[:geo_states])
        @geo_states.write({
            id: geo_state.id,
            name: geo_state.name,
            zone_id: geo_state.zone_id,

            language_ids: geo_state.language_ids,
            updated_at: geo_state.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end
    
  def send_language language
    begin
      if @language_ids.add?(language.id) && check_send_data(@languages, language, @all_updated_at[:languages])
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
            translation_need: language.translation_need,
            translation_progress: language.translation_progress,
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
  #          champion_id: language.champion_id,

            updated_at: language.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_person person
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
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_topic topic
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
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_progress_marker progress_marker
    begin
      if @progress_marker_ids.add?(progress_marker.id) && check_send_data(@progress_markers, progress_marker, @all_updated_at[:progress_markers])
        @progress_markers.write({
            id: progress_marker.id,
            name: progress_marker.name,
            topic_id: progress_marker.topic_id,
            weight: progress_marker.weight,
            status: progress_marker.status,
            number: progress_marker.number,

            description: progress_marker.description_for(external_user),
            updated_at: progress_marker.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_report report
    begin
      if @report_ids.add?(report.id) && check_send_data(@reports, report, @all_updated_at[:reports])
        impact_report_data = Hash.new
        impact_report_data = {
            progress_marker_ids: report.impact_report.progress_marker_ids,
            shareable: report.impact_report.shareable,
            translation_impact: report.impact_report.translation_impact,
        } if report.impact_report
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
            planning_report_id: report.planning_report_id,
            impact_report_id: report.impact_report_id,
            challenge_report_id: report.challenge_report_id,
            status: report.status,
            sub_district_id: report.sub_district_id,
            location: report.location,
            client: report.client,
            version: report.version,
            significant: report.significant,

            report_date: report.report_date.to_time(:utc).to_i,
            picture_ids: report.picture_ids,
            language_ids: report.language_ids,
            observer_ids: report.observer_ids,
            updated_at: report.updated_at.to_i,
            last_changed: 'online'
        }.merge(impact_report_data).to_json)
      end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def send_uploaded_file uploaded_file
    begin
      if @uploaded_file_ids.add?(uploaded_file.id) && check_send_data(@uploaded_files, uploaded_file, @all_updated_at[:uploaded_files])
        @uploaded_files.write({
            id: uploaded_file.id,
            report_id: uploaded_file.report_id,

            data: Base64.encode64(uploaded_file.ref.read),
            updated_at: uploaded_file.updated_at.to_i,
            last_changed: 'online'
        }.to_json)
     end
    rescue => e
      error_message = { error: e.to_s, where: e.backtrace.to_s }
      @users.write error_message.to_json
    end
  end

  def check_send_data file, object, offline_updated_at_reference
    return false unless object
    offline_updated_at = offline_updated_at_reference
    offline_updated_at &&= offline_updated_at[object.id.to_s]
    offline_updated_at &&= offline_updated_at[:updated_at]
    if offline_updated_at
      if object.updated_at.to_i == offline_updated_at
        return false
      elsif offline_updated_at > object.updated_at.to_i
        file.write(', ') unless file.length == 0
        file.write({id: object.id, last_changed: 'offline'}.to_json)
        return false
      end
    end
    file.write(', ') unless file.length == 0
    true
  end
  
  def send_hash_file send_message
    send_file = Tempfile.new
    send_file.write '{'
    send_message.each do |category, file|
      file.close
      file.open
      send_file.write ', ' unless send_file.length == 1
      send_file.write '"' + category.to_s + '": ['
      while buffer = file.read(512)
        send_file.write buffer.force_encoding(Encoding::CP1252).encode(Encoding::UTF_8)
      end
      send_file.write ']'
      file.close
      file.unlink
    end
    send_file.write '}'
    send_file.close
    send_file send_file.path, status: :ok
  end
  
  # receive_request methods:

  def receive_uploaded_file uploaded_file_id, uploaded_file_data
    puts 'Save file ' + uploaded_file_id.to_s + uploaded_file_data.keys.to_s
    status = uploaded_file_data.delete 'status'
    if status == 'delete'
      UploadedFile.delete uploaded_file_id
      return nil
    end
    if status != 'new'
      @errors << { 'uploaded_file_' + uploaded_file_id.to_s => 'Unknown status: ' + status }
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
      @errors << { "uploaded_file_" + uploaded_file_id.to_s => e }
      return nil
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def receive_report report_id, report_data, uploaded_files_data
    puts 'Save report ' + report_id.to_s + report_data.to_s
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
        @errors << { 'report_' + report_id.to_s => 'Couldn\'t find report' }
        return
      end
      (report.picture_ids - report_data['picture_ids']).each do |deleted_picture_id|
        receive_uploaded_file deleted_picture_id, 'status' => 'delete'
      end if report_data['picture_ids']
      if report.update(report_data) && report.impact_report.update(impact_report_data)
        report.touch
        @report_feedbacks << {
            id: report_id,
            updated_at: report.updated_at.to_i,
            last_changed: 'uploaded'
        }
      else
        @errors << { 'report_' + report_id.to_s => report.errors.messages.to_s }
      end
    elsif status == 'new'
      report = Report.new report_data
      report.impact_report = ImpactReport.new(impact_report_data) if impact_report
      error = false
      if supervisor_mail
        if send_mail(report, supervisor_mail)
          mail_info = {mail: "send successful"}
        else
          error = true
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
        @errors << {'report_' + report_id.to_s => report.errors.messages.to_s}
      end
    else
      @errors << {'report_' + report_id.to_s => 'Unknown status: ' + status}
    end
  end
  
  def send_mail report, mail
    # make sure TLS gets used for delivering this email
    if SendGridV3.enforce_tls
      recipient = User.find_by_email mail
      recipient ||= mail
      delivery_success = false
      begin
        if recipient
          puts recipient
          UserMailer.user_report(recipient, report).deliver_now 
          delivery_success = true
        end
      rescue EOFError,
            IOError,
            TimeoutError,
            Errno::ECONNRESET,
            Errno::ECONNABORTED,
            Errno::EPIPE,
            Errno::ETIMEDOUT,
            Net::SMTPAuthenticationError,
            Net::SMTPServerBusy,
            Net::SMTPSyntaxError,
            Net::SMTPUnknownError,
            OpenSSL::SSL::SSLError => e
        @errors << 'Failed to send the report to the supervisor'
        Rails.logger.error e.message
      end
      if delivery_success
        # also send it to the reporter
        UserMailer.user_report(report.reporter, report).deliver_now
        return true
      end
    else
      @errors << 'Could not ensure email encryption so didn\'t send the report to the supervisor'
      Rails.logger.error 'Could not enforce TLS with SendGrid'
    end
    false
  end
  
end
# for easily getting all attributes:
# Language.new.attributes.except("created_at","updated_at").keys.each{|k|puts "          " + k.to_s + ": xxx." + k.to_s + ","}.nil?
