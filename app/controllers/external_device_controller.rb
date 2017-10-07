class ExternalDeviceController < ApplicationController
  include ParamsHelper

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
          ExternalDevice.update user_device.id, name: full_params[:device_name]
        end
        render json: {
            user: user.id,
            jwt: create_jwt(user),
            database_key: create_database_key(user)
        }, status: :created
        return
      end
      # create the (in future unregistered) device, if it doesn't exist
      unless users_device
        new_device = ExternalDevice.new
        new_device.device_id = full_params[:device_id]
        new_device.name = full_params[:device_name]
        new_device.user = @user
        new_device.registered = true # Remove this, if manual registration is implemented
        new_device.save
        render json: {
            user: user.id,
            jwt: create_jwt(user),
            database_key: create_database_key(user)
        }, status: :created # Remove this, if manual registration is implemented
        return # Remove this, if manual registration is implemented
      end
      puts "Device not registered"
      render json: { user: @user.id, error: "Device not registered" }, status: :unauthorized
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  def get_database_key
    begin
      full_params = params.require(:session).permit :user_id, :device_id
      # Check, whether user exists and device is registered
      user = User.find_by_id(full_params['user_id'])
      users_device = user && user.external_devices.find{|d| d.device_id == full_params[:device_id]}
      unless user && users_device && users_device.registered?
        puts "Device not registered"
        render json: { error: "Device not registered" }, status: :unauthorized 
      end
      database_key = (user.created_at.to_f * 1000000).to_i
      puts database_key
      render json: { key: database_key }, status: :ok
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  def send_request
    begin
      @users, @geo_states, @languages, @reports, @uploaded_files,
      @topics, @progress_markers = Array.new(7) {Array.new}
      @all_updated_at = send_request_params
      error = ""
      if @all_updated_at[:now] > Time.now.to_i || @all_updated_at[:now] + 60 < Time.now.to_i
        error = 'Timestamp is not the same for external device and server: ' + @all_updated_at[:now].to_s + " " + Time.now.utc.to_i.to_s
      end
      send_external_user
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
      Topic.all.each{|topic| send_topic topic}
      ProgressMarker.all.each{|progress_marker| send_progress_marker progress_marker}
      Report.includes(:impact_report, :pictures).user_limited(external_user).each do |report|
        send_report report
        report.pictures.each{|picture| send_picture picture}
      end
      render json: {
          error: error,
          users: @users,
          geo_states: @geo_states,
          language: @languages.uniq,
          topics: @topics,
          progress_markers: @progress_markers,
          reports: @reports,
          uploaded_files: @uploaded_files
      }, status: :ok
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  def receive_request
    begin
      @uploaded_file_feedbacks, @report_feedbacks, @errors = Array.new(3) {Array.new}
      full_params = receive_request_params
      full_params[:reports].each_with_index do |report_params, report_id|
        receive_report report_id, report_params, full_params[:uploaded_files]
      end
      render json: {
          error: @errors,
          uploaded_file_feedbacks: @uploaded_file_feedbacks,
          report_feedbacks: @report_feedbacks
      }, status: :ok
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
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
      :now,
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
        :id,
        :data,
        :report_id
      ],
      :reports => [
        :status,
        :id,
        :geo_state_id,
        {:language_ids => []},
        :report_date,
        :content,
        :reporter_id,
        :impact_report,
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
          geo_state_ids: external_user.geo_state_ids,
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
          updated_at: language.updated_at.to_i,
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
          content: report.content,
          reporter_id: report.reporter_id,
          impact_report: true,
          languages: report.language_ids,
          pictures: report.pictures,
          client: report.client,
          version: report.version,
          markers: report.impact_report.progress_marker_ids,
          updated_at: report.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_uploaded_file uploaded_file
    if check_send_data(@uploaded_files, uploaded_file, @all_updated_at[:uploaded_files])
      @uploaded_files << {
          id: picture.id,
          updated_at: picture.updated_at.to_i,
          data: Base64.encode64(picture.ref.read)
      }
   end
  end

  def check_send_data array, object, offline_updated_at_reference
    offline_updated_at = offline_updated_at_reference
    offline_updated_at &&= offline_updated_at[object.id.to_s]
    offline_updated_at &&= offline_updated_at[:updated_at]
    if offline_updated_at
      if object.updated_at.to_i == offline_updated_at
        array << {id: object.id, last_changed: 'same'}
        return false
      end
      if object.updated_at.to_i < offline_updated_at
        array << {id: object.id, last_changed: 'offline'}
        return false
      end
    end
    true
  end

  def receive_uploaded_file uploaded_file_id, uploaded_file_data
    status = uploaded_file_data[:status]
    if status == 'delete'
      ExternalFile.delete uploaded_file_id
      return nil
    end
    if status != 'new'
      @errors << {uploaded_file_id => 'Unknown status'}
      return nil
    end
    # convert image-string to image-file
    begin
      filename = 'external_uploaded_image'
      tempfile = Tempfile.new filename
      tempfile.binmode
      tempfile.write Base64.decode64 uploaded_file_data.delete(:data)
      tempfile.rewind
      content_type = `file --mime -b #{tempfile.path}`.split(';')[0]
      extension = content_type.match(/gif|jpg|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      uploaded_file_data[:ref] = UploadedFile.new({
          tempfile: tempfile,
          type: content_type,
          filename: filename
      })
      uploaded_file = UploadedFile.new(uploaded_file_data).save
      uploaded_file_feedbacks << {id: uploaded_file_id, updated_at: uploaded_file.updated_at.to_i, new_id: uploaded_file.id}
      return uploaded_file.id
    rescue => e
      @errors << {uploaded_file_id => e}
      return nil
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def receive_report report_id, report_data, uploaded_files_data
    impact_report = data.delete :impact_report
    status = data.delete :status
    data[:picture_ids] && data[:picture_ids].map! do |picture_id|
      picture_id = picture_id.to_i
      picture_data = uploaded_file_data[picture_id]
      if picture_data
        receive_uploaded_file picture_id, picture_data
      else
        picture_id
      end
    end
    if status == 'old'
      report = Report.find_by_id report_id
      if report
        (report.picture_ids - data[:picture_ids]).each do |deleted_picture_id|
          receive_uploaded_file deleted_picture_id, status: 'delete'
        end
        if report.update(data)
          @report_feedbacks << {id: report_id, updated_at: report.updated_at.to_i}
        else
          @errors << {report_id => report.errors.messages}
        end
        return
      else
        status = 'new'
      end
    end
    if status == 'new'
      report = Report.new data
      report.impact_report = ImpactReport.new if impact_report
      if report.save
        @report_feedbacks << {id: report_id, updated_at: report.updated_at.to_i, new_id: report.id}
      else
        @errors << {report_id => report.errors.messages}
      end
    else
      @errors << {report_id => 'Unknown status'}
    end
  end
end
