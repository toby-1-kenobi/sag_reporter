module MinistriesHelper

  def projects_overview_data(zones, stream, quarter)
    first_month, last_month  = quarter_to_range(quarter)
    data = {}
    zones.each do |zone|
      # facilitator, sum of all
      data[zone] = zone.aggregate_ministry_outputs.joins(:deliverable).
          where('aggregate_ministry_outputs.month >= ?', first_month).
          where('aggregate_ministry_outputs.month <= ?', last_month).
          where(actual: true, deliverables: {ministry_id: stream, reporter: 1,  calculation_method: 1}).
          group(:deliverable_id).sum(:value)
      # facilitator, most recent
      # we must find the most recent month reported in each state-language and sum those
      amos = zone.aggregate_ministry_outputs.joins(:deliverable).
          where('aggregate_ministry_outputs.month >= ?', first_month).
          where('aggregate_ministry_outputs.month <= ?', last_month).
          where(actual: true, deliverables: {ministry_id: stream, reporter: 1, calculation_method: 0}).
          to_a.group_by(&:deliverable_id)
      amos.each do |del_id, amo_list|
        grouped_amo_list = amo_list.group_by(&:state_language_id)
        data[zone][del_id] = 0
        grouped_amo_list.values.each do |amo_sub_list|
          max_month = amo_sub_list.max_by{ |amo| amo.month }.month
          data[zone][del_id] += amo_sub_list.select{ |amo| amo.month == max_month }.sum(&:value)
        end
      end
      # church team, sum of all
      zone.ministry_outputs.joins(:deliverable).
          where('ministry_outputs.month >= ?', first_month).
          where('ministry_outputs.month <= ?', last_month).
          where(actual: true, deliverables: {ministry_id: stream, reporter: 0, calculation_method: 1}).
          group(:deliverable_id).sum(:value)
      # church team, most recent
      # we must find the most recent month reported in each state-language and sum those
      mos = zone.ministry_outputs.includes(:deliverable, church_ministry: :church_team).
          where('ministry_outputs.month >= ?', first_month).
          where('ministry_outputs.month <= ?', last_month).
          where(actual: true, deliverables: {ministry_id: stream, reporter: 0, calculation_method: 0}).
          to_a.group_by(&:deliverable_id)
      mos.each do |del_id, mo_list|
        grouped_amo_list = mo_list.group_by{ |mo| mo.church_ministry.church_team.state_language_id }
        data[zone][del_id] = 0
        grouped_amo_list.values.each do |mo_sub_list|
          max_month = mo_sub_list.max_by{ |mo| mo.month }.month
          data[zone][del_id] += mo_sub_list.select{ |mo| mo.month == max_month }.sum(&:value)
        end
      end
      # auto calculated deliverables
      stream.deliverables.auto.each do |deliverable|
        data[zone][deliverable.id] = auto_actuals(zone, nil, deliverable, first_month, last_month)
      end
    end
    data
  end

  def aggregate_targets(zones, stream, quarter)
    targets = {}
    zones.each do |zone|
      targets[zone.id] = zone.quarterly_targets.where(quarter: quarter, deliverable: stream.deliverables).group(:deliverable_id).sum(:value)
    end
    targets
  end

end
