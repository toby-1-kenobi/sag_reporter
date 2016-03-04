require_relative "factory_floor"

class Report::Updater

  include Report::FactoryFloor

  attr_reader :instance
  attr_reader :error

  def initialize(report)
    @instance = report
  end

  def update_report(params)
    language_ids = params.delete 'languages'
    topic_ids = params.delete 'topics'
    impact = params.delete 'impact_report'
    planning = params.delete 'planning_report'
    challenge = params.delete 'challenge_report'
    begin
      result = @instance.update_attributes(params)
      @instance.languages.clear
      add_languages(language_ids) if language_ids
      @instance.topics.clear
      add_topics(topic_ids) if topic_ids
      @instance.planning_report = nil if planning.to_i == 0
      @instance.impact_report = nil if impact.to_i == 0
      @instance.challenge_report = nil if challenge.to_i == 0
      if @instance.planning_report.blank? and planning.to_i == 1
        @instance.planning_report = PlanningReport.new
      end
      if @instance.impact_report.blank? and impact.to_i == 1
        @instance.impact_report = ImpactReport.new
      end
      if @instance.challenge_report.blank? and challenge.to_i == 1
        @instance.challenge_report = ChallengeReport.new
      end
      @instance.save!
    rescue => e
      error = e
      return false
    else
      return result
    end
  end

end