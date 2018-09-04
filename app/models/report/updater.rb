require_relative "factory_floor"

class Report::Updater

  include Report::FactoryFloor

  attr_reader :instance
  attr_reader :error

  def initialize(report)
    @instance = report
  end

  def update_report(params)
    state_language_ids = params.delete 'languages'
    observers = params.delete 'observers_attributes'
    impact = params.delete 'impact_report'
    impact_attr = params.delete 'impact_report_attributes'
    planning = params.delete 'planning_report'
    challenge = params.delete 'challenge_report'
    begin
      result = @instance.update_attributes(params)
      @instance.languages.clear
      add_languages(state_language_ids, @instance.geo_state_id) if state_language_ids
      @instance.topics.clear
      @instance.observers.clear
      add_observers(observers, @instance.geo_state_id, @instance.reporter) if observers

      if @instance.planning_report.present? and planning.to_i == 0
        report = @instance.planning_report
        @instance.update_attribute(:planning_report_id, nil)
        report.destroy
      end
      if @instance.impact_report.present? and impact.to_i == 0
        report = @instance.impact_report
        @instance.update_attribute(:impact_report_id, nil)
        report.destroy
      end
      if @instance.challenge_report.present? and challenge.to_i == 0
        report = @instance.challenge_report
        @instance.update_attribute(:challenge_report_id, nil)
        report.destroy
      end

      if @instance.planning_report.blank? and planning.to_i == 1
        @instance.planning_report = PlanningReport.new
      end
      if @instance.impact_report.blank? and impact.to_i == 1
        @instance.impact_report = ImpactReport.new
      end
      if @instance.challenge_report.blank? and challenge.to_i == 1
        @instance.challenge_report = ChallengeReport.new
      end
      add_impact_attr(impact_attr) if impact_attr and impact.to_i == 1
      @instance.save!
      return result
    rescue => e
      Rails.logger.error(e.message)
      return false
    end
  end

end
