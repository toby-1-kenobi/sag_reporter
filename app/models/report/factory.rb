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
    begin
      @instance = Report.new(params)
      add_languages(state_language_ids, params['geo_state_id']) if state_language_ids
      add_topics(topic_ids) if topic_ids
      add_observers(observers, params['geo_state_id'], params[:reporter]) if observers
      @instance.impact_report = ImpactReport.new if impact.to_i == 1
      @instance.planning_report = PlanningReport.new if planning.to_i == 1
      @instance.challenge_report = ChallengeReport.new if challenge.to_i == 1
    rescue => e
      @error = e
      return false
    else
      return true
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