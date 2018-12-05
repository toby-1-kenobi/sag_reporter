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
          where('church_teams.state_language_id = ?', state_language_id).
          where(ministry: deliverable.ministry)
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
        outputs.inject(0) { |sum, mo| sum + mo.value }      end
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
      auto_actuals(StateLanguage.find(state_language_id), deliverable, first_month, last_month) or '!'
    else
      '?'
    end
  end

  def auto_actuals(state_language, deliverable, first_month, last_month)
    raise ArgumentError.new("deliverable not auto-calculated") unless deliverable.auto?
    case "#{deliverable.ministry.code}#{deliverable.number}"
    when 'SU11', 'SC4', 'ET2', 'ST3', 'ES3', 'TR8' # Impact stories through this stream
      first_day = Date.new(first_month[0..3].to_i, first_month[-2..-1].to_i, 1)
      last_day = Date.new(last_month[0..3].to_i, last_month[-2..-1].to_i).end_of_month
      Report.joins(:impact_report, :languages, :report_streams).
          where(languages: {id: state_language.language_id}, geo_state_id: state_language.geo_state_id).
          where(report_streams: {ministry_id: deliverable.ministry_id}).
          where('report_date >= ?', first_day).where('report_date <= ?', last_day).
          count
    when 'CH1' # Active church teams
      # assume active if recording any actuals in the last month
      query = ChurchTeam.joins(church_ministries: :ministry_outputs).where(state_language: state_language)
      prev_month = 1.month.ago.strftime('%Y-%m')
      if (prev_month < last_month)
        query = query.where('ministry_outputs.month >= ?', prev_month)
      else
        query = query.where('ministry_outputs.month = ?', last_month)
      end
      query.select('church_teams.id').distinct.count
    else
      Rails.logger.error "Auto calculation for deliverable #{deliverable.id} not implemented."
      nil
    end
  end

end
