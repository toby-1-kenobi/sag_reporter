require_relative "factory_floor"

class Report::Factory

  include Report::FactoryFloor

  attr_reader :instance
  attr_reader :error

  def build_report(params)
    @error = nil
    state_language_ids = params.delete 'languages'
    observers = params.delete 'observers_attributes'
    impact = params.delete 'impact_report'
    impact_attr = params.delete 'impact_report_attributes'
    planning = params.delete 'planning_report'
    challenge = params.delete 'challenge_report'
    Rails.logger.debug params
    if (!params['client'])
      params['client'] = SagReporter::Application::APP_SHORT_NAME
      params['version'] ||= SagReporter::Application::VERSION
    end
    begin
      @instance = Report.new(params)
      add_languages(state_language_ids, params['geo_state_id']) if state_language_ids
      add_observers(observers, params['geo_state_id'], params[:reporter]) if observers
      if impact.to_i == 1
        @instance.impact_report = ImpactReport.new
        add_impact_attr(impact_attr) if impact_attr
      end
      @instance.planning_report = PlanningReport.new if planning.to_i == 1
      @instance.challenge_report = ChallengeReport.new if challenge.to_i == 1
      return true
    rescue => e
      @error = e
      return false
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
