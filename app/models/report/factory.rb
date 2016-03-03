class Report::Factory

  attr_reader :instance
  attr_reader :error

  def build_report(params)
    language_ids = params.delete 'languages'
    topic_ids = params.delete 'topics'
    impact = params.delete 'impact_report'
    planning = params.delete 'planning_report'
    challenge = params.delete 'challenge_report'
    begin
      @instance = Report.new(params)
      add_languages(language_ids.values) if language_ids
      add_topics(topic_ids.values) if topic_ids
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

  private

  def add_languages(language_ids)
    @instance.languages << Language.where(id: language_ids)
  end

  def add_topics(topic_ids)
    @instance.topics << Topic.where(id: topic_ids)
  end

end