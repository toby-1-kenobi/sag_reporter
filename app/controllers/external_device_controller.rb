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
      @people, @topics, @progress_markers = Array.new(8) {Array.new}
      @all_updated_at = send_request_params
      send_external_user
      send_language external_user.mother_tongue
      external_user.spoken_languages.each{|language| send_language language}
      send_language external_user.interface_language
      external_user.championed_languages.each{|language| send_language language}
      User.all.each{|user| send_user(user) if user != external_user}
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
      Topic.all.each{|topic| send_topic topic}
      ProgressMarker.all.each{|progress_marker| send_progress_marker progress_marker}
      Report.includes(:impact_report, :pictures).user_limited(external_user).each do |report|
        send_report report
        report.pictures.each{|picture| send_uploaded_file picture}
      end
      send_message = {
          users: @users,
          geo_states: @geo_states,
          languages: @languages.uniq,
          people: @people,
          topics: @topics,
          progress_markers: @progress_markers,
          reports: @reports,
          uploaded_files: @uploaded_files
      }
      puts send_message
      render json: send_message, status: :ok
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
      :uploaded_files => [:updated_at]
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

  def send_external_user
    if check_send_data(@users, external_user, @all_updated_at[:users])
      @users << {
          id: external_user.id,
          name: external_user.name,
          phone: external_user.phone,
          email: external_user.email,
          email_confirmed: external_user.email_confirmed,
          geo_state_ids: external_user.geo_state_ids,
          trusted: external_user.trusted,
          national: external_user.national,
          admin: external_user.admin,
          national_curator: external_user.national_curator,
          mother_tongue_id: external_user.mother_tongue_id,
          spoken_language_ids: external_user.spoken_language_ids,
          interface_language_id: external_user.interface_language_id,
          championed_language_ids: external_user.championed_language_ids,
          updated_at: external_user.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_user user
    if check_send_data(@users, user, @all_updated_at[:users])
      @users << {
          id: user.id,
          name: user.name,
          updated_at: user.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_geo_state geo_state
    if check_send_data(@geo_states, geo_state, @all_updated_at[:geo_states])
      @geo_states << {
          id: geo_state.id,
          name: geo_state.name,
          language_ids: geo_state.language_ids,
          updated_at: geo_state.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end
    
  def send_language language
    if check_send_data(@languages, language, @all_updated_at[:languages])
      @languages << {
          id: language.id,
          name: language.name,
          colour: language.colour,
          iso: language.iso,
          updated_at: language.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_person person
    if check_send_data(@people, person, @all_updated_at[:people])
      @people << {
          id: person.id,
          name: person.name,
          description: person.description,
          phone: person.phone,
          address: person.address,
          intern: person.intern,
          facilitator: person.facilitator,
          pastor: person.pastor,
          mother_tongue_id: person.language_id,
          record_creator_id: person.user_id,
          geo_state_id: person.geo_state_id,
          updated_at: person.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_topic topic
    if check_send_data(@topics, topic, @all_updated_at[:topics])
      @topics << {
          id: topic.id,
          name: topic.name,
          description: topic.description,
          colour: topic.colour,
          updated_at: topic.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_progress_marker progress_marker
    if check_send_data(@progress_markers, progress_marker, @all_updated_at[:progress_markers])
      @progress_markers << {
          id: progress_marker.id,
          name: progress_marker.name,
          alternate_description: progress_marker.alternate_description,
          topic_id: progress_marker.topic_id,
          number: progress_marker.number,
          updated_at: progress_marker.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_report report
    if check_send_data(@reports, report, @all_updated_at[:reports])
      @reports << {
          id: report.id,
          state_id: report.geo_state_id,
          date: report.report_date.to_time(:utc).to_i,
          picture_ids: report.picture_ids,
          content: report.content,
          reporter_id: report.reporter_id,
          impact_report: true,
          language_ids: report.language_ids,
          client: report.client,
          version: report.version,
          status: report.status,
          progress_marker_ids: report.impact_report.progress_marker_ids,
          observer_ids: report.observer_ids,
          updated_at: report.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_uploaded_file uploaded_file
    if check_send_data(@uploaded_files, uploaded_file, @all_updated_at[:uploaded_files])
      @uploaded_files << {
          id: uploaded_file.id,
          data: Base64.encode64(uploaded_file.ref.read),
          report_id: uploaded_file.report_id,
          updated_at: uploaded_file.updated_at.to_i,
          last_changed: 'online'
      }
   end
  end

  def check_send_data array, object, offline_updated_at_reference
    return false unless object
    offline_updated_at = offline_updated_at_reference
    offline_updated_at &&= offline_updated_at[object.id.to_s]
    offline_updated_at &&= offline_updated_at[:updated_at]
    if offline_updated_at
      if object.updated_at.to_i == offline_updated_at
        array << {id: object.id, last_changed: 'same'}
        return false
      end
      if offline_updated_at > 0 # > object.updated_at.to_i
        array << {id: object.id, last_changed: 'offline'}
        return false
      end
    end
    true
  end

  def receive_uploaded_file uploaded_file_id, uploaded_file_data
    puts 'Save file ' + uploaded_file_id.to_s + uploaded_file_data.keys.to_s
    status = uploaded_file_data.delete 'status'
    if status == 'delete'
      ExternalFile.delete uploaded_file_id
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
    report_data['report_date'] &&= Time.now
    report_data['picture_ids'] && report_data['picture_ids'].map! do |picture_id|
      picture_id = picture_id.to_i
      picture_data = uploaded_files_data[picture_id.to_s]
      if picture_data
        receive_uploaded_file picture_id, picture_data
      else
        picture_id
      end
    end
    if status == 'old'
      report = Report.find_by_id report_id
      unless report
        @errors << { 'report_' + report_id.to_s => 'Couldn\'t find report' }
        return
      end
      (report.picture_ids - report_data['picture_ids']).each do |deleted_picture_id|
        receive_uploaded_file deleted_picture_id, status: 'delete'
      end if report_data['picture_ids']
      if report.update(report_data)
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
      report.impact_report = ImpactReport.new if impact_report
      if report.save
        @report_feedbacks << {
            id: report_id,
            updated_at: report.updated_at.to_i,
            new_id: report.id,
            last_changed: 'uploaded'
        }
      else
        @errors << {'report_' + report_id.to_s => report.errors.messages.to_s}
      end
    else
      @errors << {'report_' + report_id.to_s => 'Unknown status: ' + status}
    end
  end
end
