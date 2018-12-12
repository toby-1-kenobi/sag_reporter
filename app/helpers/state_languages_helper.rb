module StateLanguagesHelper

  def dashboard_state_languages(dashboard_type)
    case dashboard_type
    when :state
      @geo_state.state_languages.includes(:language).order('languages.name')
    when :zone
      @zone.state_languages.includes(:language).order('languages.name')
    else
      StateLanguage.all.includes(:language).order('languages.name')
    end
  end

  def quarterly_actual(state_language_id, deliverable, quarter, project, sub_project)
    first_month, last_month = quarter_to_range(quarter)
    case deliverable.reporter
    when 'church_team'
      church_mins = ChurchMinistry.joins(:church_team).
          where(church_teams: {state_language_id: state_language_id}, ministry: deliverable.ministry)
      # if sub_project
      #   fac_ids = sub_project.language_streams.
      #       where(state_language_id: state_language_id, ministry_id: deliverable.ministry_id).
      #       pluck :facilitator_id
      #   church_mins = church_mins.where(facilitator_id: fac_ids)
      # end
      outputs = MinistryOutput.
          where(actual: true, church_ministry: church_mins, deliverable: deliverable).
          where('month >= ?', first_month).
          where('month <= ?', last_month)
      if outputs.empty?
        '-'
      else
        if deliverable.most_recent?
          month = outputs.order(:month).last.month
          outputs = outputs.where(month: month)
        end
        outputs.inject(0) { |sum, mo| sum + mo.value }
      end
    when 'facilitator'
      lang_streams = LanguageStream.where(project: project, state_language_id: state_language_id, ministry: deliverable.ministry)
      if sub_project
        lang_streams = lang_streams.where(sub_project: sub_project)
      end
      outputs = AggregateMinistryOutput.
          where(actual: true, state_language_id: state_language_id, deliverable: deliverable, creator_id: lang_streams.pluck(:facilitator_id)).
          where('month >= ?', first_month).
          where('month <= ?', last_month)
      if outputs.empty?
        '-'
      else
        if deliverable.most_recent?
          month = outputs.order(:month).last.month
          outputs = outputs.where(month: month)
        end
        outputs.inject(0) { |sum, mo| sum + mo.value }
      end
    when 'auto'
      auto_actuals(nil, StateLanguage.find(state_language_id), deliverable, first_month, last_month) or '!'
    else
      '?'
    end
  end

  # if state_language is not nil zone is ignored, and scope is to state_language
  # if state_language is nil scope is to zone
  # if both zone and state_language are nil scope is to nation
  def auto_actuals(zone, state_language, deliverable, first_month, last_month)
    raise ArgumentError.new("deliverable not auto-calculated") unless deliverable.auto?
    raise ArgumentError.new("first month must not be after last month") if first_month > last_month
    case "#{deliverable.ministry.code}#{deliverable.number}"
    when 'SU11', 'SC4', 'ET2', 'ST3', 'ES3', 'TR8' # Impact stories through this stream
      first_day = Date.new(first_month[0..3].to_i, first_month[-2..-1].to_i, 1)
      last_day = Date.new(last_month[0..3].to_i, last_month[-2..-1].to_i).end_of_month
      query = Report.joins(:impact_report, :geo_state, :languages, :report_streams).
          where(report_streams: {ministry_id: deliverable.ministry_id}).
          where('report_date >= ?', first_day).where('report_date <= ?', last_day)
      if state_language
        query = query.where(languages: { id: state_language.language_id }, geo_state_id: state_language.geo_state_id)
      elsif zone
        query = query.where(geo_states: { zone_id: zone.id })
      end
      query.count
    when 'CH1' # Active church teams
      # assume active if recording any actuals in the month
      # report the best month of the latest 3
      results = []
      month = Date.new(last_month[0..3].to_i, last_month[-2..-1].to_i) - 2.months
      index_month = month.strftime('%Y-%m')
      while index_month <= last_month
        query = ChurchTeam.joins({ state_language: :geo_state }, { church_ministries: :ministry_outputs }).
            where(ministry_outputs: { month: index_month })
        if state_language
          query = query.where(state_language: state_language)
        elsif zone
          query = query.where(geo_states: { zone_id: zone.id })
        end
        results << query.select('church_teams.id').distinct.count
        month = month + 1.month
        index_month = month.strftime('%Y-%m')
      end
      results.max
    when 'CH12' # Hours by Volunteer leaders
      # sum of LT10, ST8, ES9, SC8, TR12
      total_hours = 0
      deliverable_ids = Deliverable.joins(:ministry).where(ministries: {code: 'LT'}, number: 10).pluck :id
      deliverable_ids += Deliverable.joins(:ministry).where(ministries: {code: 'ST'}, number: 8).pluck :id
      deliverable_ids += Deliverable.joins(:ministry).where(ministries: {code: 'ES'}, number: 9).pluck :id
      deliverable_ids += Deliverable.joins(:ministry).where(ministries: {code: 'SC'}, number: 8).pluck :id
      deliverable_ids += Deliverable.joins(:ministry).where(ministries: {code: 'TR'}, number: 12).pluck :id
      outputs = MinistryOutput.joins(church_ministry: { church_team: { state_language: :geo_state } }).
          where(actual: true, deliverable: deliverable_ids).
          where('month >= ?', first_month).where('month <= ?', last_month)
      if state_language
        outputs = outputs.where(church_teams: { state_language_id: state_language.id })
      elsif zone
        outputs = outputs.where(geo_states: { zone_id: zone.id })
      end
      total_hours += outputs.inject(0) { |sum, mo| sum + mo.value }
      total_hours
    else
      Rails.logger.error "Auto calculation for deliverable #{deliverable.id} not implemented."
      nil
    end
  end

  def assessment(target, actual)
    begin
      target = Integer(target)
      actual = Integer(actual)
    rescue ArgumentError
      return ''
    end
    diff = actual - target
    percent = 100.0 * diff / target
    case percent
    when -20.0..20.0
      'on-pace'
    when 20.0..Float::INFINITY
      'ahead'
    when -40.0..20.0
      'somewhat-behind'
    else
      'behind'
    end
  end

end
