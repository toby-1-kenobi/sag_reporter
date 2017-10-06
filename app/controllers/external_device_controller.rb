class ExternalDeviceController < ApplicationController
  include ParamsHelper

  skip_before_action :verify_authenticity_token
#  before_action :authenticate_external

  def test_server
    head :ok
  end

  def send_request
    begin
      @users, @geo_states, @languages, @reports, @external_files = Array.new(5) {Array.new}
      @all_updated_at = send_params
      if @all_updated_at[:now] > Time.now.to_i || @all_updated_at[:now] + 60 < Time.now.to_i
#        throw 'Timestamp is not the same for external device and server'
      end
      send_external_user
      User.all.each{|user| send_user user}
      GeoState.all.each{|geo_state| send_geo_state geo_state}
      Language.all.each{|language| send_language language}
      Report.all.each{|report| send_report report}
      render json: {
          users: @users,
          geo_states: @geo_states,
          language: @languages,
          reports: @reports,
          external_files: @external_files
      }, status: :ok
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  def receive_request
    begin
      @external_file_feedbacks, @report_feedbacks = Array.new 2, Array.new
      received_params = receive_params
      received_params[:external_files].each{|external_file_params| receive_external_file external_file_params}
      received_params[:reports].each{|report_params| receive_report report_params}
      render json: {
          external_file_feedbacks: @external_file_feedbacks,
          report_feedbacks: @report_feedbacks
      }, status: :ok
    rescue => e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  private

  def send_params
    safe_params = [
      :now,
      :users => [:updated_at],
      :languages => [:updated_at],
      :geo_states => [:updated_at],
      :reports => [:updated_at],
      :external_files => [:updated_at]
    ]
    permitted = params.require(:external_device).permit(safe_params)
  end

  def receive_params
    safe_params = [
      :external_files => [
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
    if send_data(@users, external_user, @all_updated_at[:users])
      @users << {
          id: external_user.id,
          name: external_user.name,
          geo_state_ids: external_user.geo_state_ids,
          updated_at: external_user.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_geo_state geo_state
    if send_data(@geo_states, geo_state, @all_updated_at[:geo_states])
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
    if send_data(@languages, language, @all_updated_at[:languages])
      @languages << {
          id: language.id,
          name: language.name,
          updated_at: language.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_user user
    return if user == external_user
    if send_data(@users, user, @all_updated_at[:users])
      @users << {
          id: user.id,
          name: user.name,
          updated_at: user.updated_at.to_i,
          last_changed: 'online'
      }
    end
  end

  def send_report report
    if send_data(@reports, report, @all_updated_at[:reports])
      report.pictures.each{|picture| send_picture picture}
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

  def send_picture picture
    if picture.ref.file.exists?
      if send_data(@reports, report, @all_updated_at[:external_files])
        file_content = Base64.encode64 picture.ref.read
        @external_files << {
            id: picture.id,
            updated_at: picture.updated_at.to_i,
            data: file_content
        }
     end
    else
      throw 'File doesn\'t exist'
    end
  end

  def send_data array, object, offline_updated_at_reference
    offline_updated_at = offline_updated_at_reference[object.id]
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

  def receive_external_file external_file_data
    status = external_file_data[:status]
    external_file_id = external_file_data[:id]
    if status == 'delete'
      return ExternalFile.delete external_file_id
    end
    if status != 'new'
      throw 'Unknown status'
    end
    # convert image-string to image-file
    begin
      # create new temporal image file
      filename = 'external_uploaded_image'
      tempfile = Tempfile.new filename
      tempfile.binmode
      tempfile.write Base64.decode64 external_file_data.delete(:data)
      tempfile.rewind
      # get the type of the file
      content_type = `file --mime -b #{tempfile.path}`.split(';')[0]
      # add the type-extension to the filename
      extension = content_type.match(/gif|jpg|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      # save the file
      external_file_data[:ref] = UploadedFile.new({
          tempfile: tempfile,
          type: content_type,
          filename: filename
      })
      external_file = ExternalFile.new(external_file_data).save
    rescue => e
      throw e
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink
      end
    end
    external_file_feedbacks << {id: external_file.id, updated_at: external_file.updated_at.to_i, old_id: external_file_id}
  end

  def receive_report report_data
    impact_report = report_data.delete :impact_report
    status = report_data.delete :status
    old_id = {}
    if status == 'new'
      old_id = {old_id: report_data.delete(:id)}
      report = Report.new report_data
      report.impact_report = ImpactReport.new if impact_report
      report.save
    elsif status == 'old'
      report = Report.update report_data[:id], report_data
    else
      throw 'Unknown status'
    end
    @report_feedbacks << {id: report.id, updated_at: report.updated_at.to_i}.merge(old_id)
  end
end
