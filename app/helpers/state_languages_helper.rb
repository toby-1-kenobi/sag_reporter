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
    months = months_in_quarter(quarter[-1].to_i)
    first_month = "#{year_from_app_year(quarter[0..3].to_i, months.first)}-#{months.first.to_s.rjust(2, '0')}"
    last_month = "#{year_from_app_year(quarter[0..3].to_i, months.last)}-#{months.last.to_s.rjust(2, '0')}"
    case deliverable.reporter
    when 'church_team'
      church_mins = ChurchMinistry.joins(:church_team).
          where('church_teams.state_language_id = ?', state_language_id).
          where(ministry: deliverable.ministry)
      if sub_project
        fac_ids = sub_project.language_streams.
            where(state_language_id: state_language_id, ministry_id: deliverable.ministry_id).
            pluck :facilitator_id
        church_mins = church_mins.where(facilitator_id: fac_ids)
      end
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
    else
      '?'
    end
  end

end
