module QuarterlyTargetsHelper

  def year_targets(state_language, deliverable, year)
    QuarterlyTarget.year(year).where(state_language: state_language, deliverable: deliverable)
  end

  def calculate_annual_target(q_targets, deliverable)
    case deliverable.calculation_method
    when 'sum_of_all'
      return q_targets.inject(0){ |sum, q_target| sum + q_target.value }
    when 'most_recent'
      return q_targets.any? ? q_targets.order(:quarter).last.value : 0
    else
      Rails.logger.error("unknown deliverable calculation method: #{deliverable.calculation_method}")
      return 'error'
    end
  end

end
