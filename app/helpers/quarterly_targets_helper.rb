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

  def calculate_fac_annual_actual(state_language, deliverable, year)
    last_month = Date.new(year, Rails.configuration.year_cutoff_month) - 1.month
    first_month = last_month - 11.months
    amos = state_language.aggregate_ministry_outputs.
        where(deliverable: deliverable, actual: true).
        where('month >= ?', first_month.strftime("%Y-%m")).
        where('month <= ?', last_month.strftime("%Y-%m")).
        order(:month)
    if deliverable.most_recent?
      return amos.any? ? amos.last.value : 0
    else
      amos.inject(0) { |sum, amo| sum + amo.value }
    end
  end

end
