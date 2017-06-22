require_relative "factory_floor"

class Report::Factory

  include Report::FactoryFloor

  attr_reader :instance
  attr_reader :error

  def build_report(params)
    @error = nil
    state_language_ids = params.delete 'languages'
    topic_ids = params.delete 'topics'
    observers = params.delete 'observers_attributes'
    impact = params.delete 'impact_report'
    planning = params.delete 'planning_report'
    challenge = params.delete 'challenge_report'
    if (!params['client'])
      params['client'] = SagReporter::Application::APP_SHORT_NAME
      params['version'] ||= SagReporter::Application::VERSION
    end
    if params['pictures_attributes'].try(:values).try(:first).try(:values).try(:first) == "created_external"
      # convert image-strings to image-files
      base64_data = params['pictures_attributes']
      tempfiles = Array.new
      base64_data.each do |image_number, image_data|
        filename = "upload-image" + image_number
        tempfile = Tempfile.new(filename)
        tempfile.binmode
        tempfile.write Base64.decode64(image_data["created_external"])
        tempfile.rewind
        # for security we want the actual content type, not just what was passed in
        content_type = `file --mime -b #{tempfile.path}`.split(";")[0]

        # we will also add the extension ourselves based on the above
        # if it's not gif/jpeg/png, it will fail the validation in the upload model
        extension = content_type.match(/gif|jpg|jpeg|png/).to_s
        filename += ".#{extension}" if extension
        params['pictures_attributes'][image_number].except! "created_external"
        params['pictures_attributes'][image_number]['ref'] =
            ActionDispatch::Http::UploadedFile.new({
                tempfile: tempfile,
                type: content_type,
                filename: filename
                                                   })
        tempfiles.push tempfile
      end
    end
    begin
      @instance = Report.new(params)
      add_languages(state_language_ids, params['geo_state_id']) if state_language_ids
      add_topics(topic_ids) if topic_ids
      add_observers(observers, params['geo_state_id'], params[:reporter]) if observers
      @instance.impact_report = ImpactReport.new if impact.to_i == 1
      @instance.planning_report = PlanningReport.new if planning.to_i == 1
      @instance.challenge_report = ChallengeReport.new if challenge.to_i == 1
      success = true
    rescue => e
      @error = e
      success = false
    ensure
      tempfiles.each do |tempfile|
        if tempfile
          tempfile.close
          tempfile.unlink
        end
      end if tempfiles
      success
    end
  end

  def create_report(params)
    if build_report(params)
      return @instance.save
    else
      return false
    end
  end

end