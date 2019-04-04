module MinistriesHelper

  def projects_overview_data(zones, stream, quarter, deliverables, sl_by_zone, cm_by_zone)
    first_month, last_month  = quarter_to_range(quarter)
    amos = AggregateMinistryOutput.
        where('month BETWEEN ? AND ?', first_month, last_month).
        where(deliverable_id: deliverables.map{ |d| d[:id] }, actual: true).
        pluck_to_struct :state_language_id, :deliverable_id, :month, :value
    mos = MinistryOutput.
        where('month BETWEEN ? AND ?', first_month, last_month).
        where(deliverable_id: deliverables.map{ |d| d[:id] }, actual: true).
        pluck_to_struct :church_ministry_id, :deliverable_id, :month, :value
    data = {}
    group_del = deliverables.group_by{ |d| [d[:reporter], d[:calc_method]] }
    zones.each do |zone|
      state_languages = sl_by_zone[zone.id]
      # facilitator, sum of all
      fac_sum_del = group_del[['facilitator', 'sum_of_all']]
      if fac_sum_del
        data[zone.id] = amos.
            select{ |amo| state_languages.include? amo.state_language_id and fac_sum_del.map{ |d| d[:id] }.include? amo.deliverable_id }.
            group_by(&:deliverable_id).map{ |d, v| [d, v.sum(&:value)] }.to_h
      else
        data[zone.id] = {}
      end

      # facilitator, most recent
      # we must find the most recent month reported in each state-language and sum those
      fac_rec_del = group_del[['facilitator', 'most_recent']]
      if fac_rec_del
        fac_amos = amos.
            select{ |amo| state_languages.include? amo.state_language_id and fac_rec_del.map{ |d| d[:id] }.include? amo.deliverable_id }.
            group_by(&:deliverable_id)
        fac_amos.each do |del_id, amo_list|
          grouped_amo_list = amo_list.group_by(&:state_language_id)
          data[zone.id][del_id] = 0
          grouped_amo_list.values.each do |amo_sub_list|
            max_month = amo_sub_list.max_by{ |amo| amo.month }.month
            data[zone.id][del_id] += amo_sub_list.select{ |amo| amo.month == max_month }.sum(&:value)
          end
        end
      end

      church_mins = cm_by_zone[zone.id]
      # church team, sum of all
      ct_sum_del = group_del[['church_team', 'sum_of_all']]
      if ct_sum_del
        ct_values = mos.
            select{ |amo| church_mins.include? amo.church_ministry_id and ct_sum_del.map{ |d| d[:id] }.include? amo.deliverable_id }.
            group_by(&:deliverable_id).map{ |d, v| [d, v.sum(&:value)] }.to_h
        data[zone.id].merge!(ct_values)
      end

      # church team, most recent
      # we must find the most recent month reported in each state-language and sum those
      ct_rec_del = group_del[['church_team', 'most_recent']]
      if ct_rec_del
        ct_mos = mos.
            select{ |amo| state_languages.include? amo.state_language_id and ct_rec_del.map{ |d| d[:id] }.include? amo.deliverable_id }.
            group_by(&:deliverable_id)
        ct_mos.each do |del_id, mo_list|
          grouped_amo_list = mo_list.group_by{ |mo| mo.church_ministry.church_team.state_language_id }
          data[zone.id][del_id] = 0
          grouped_amo_list.values.each do |mo_sub_list|
            max_month = mo_sub_list.max_by{ |mo| mo.month }.month
            data[zone.id][del_id] += mo_sub_list.select{ |mo| mo.month == max_month }.sum(&:value)
          end
        end
      end
      # auto calculated deliverables
      stream.deliverables.auto.each do |deliverable|
        data[zone.id][deliverable.id] = auto_actuals(zone, nil, deliverable, first_month, last_month)
      end
    end
    data
  end

  def aggregate_targets(zones, quarter, deliverables, sl_by_zone)
    targets = {}
    zones.each do |zone|
      state_languages = sl_by_zone[zone.id]
      targets[zone.id] = QuarterlyTarget.
          where(state_language_id: state_languages, quarter: quarter, deliverable: deliverables.map{ |d| d[:id] }).
          pluck_to_struct(:deliverable_id, :value).
          group_by(&:deliverable_id).map{ |d, v| [d, v.sum(&:value)] }.to_h
    end
    targets
  end

end
