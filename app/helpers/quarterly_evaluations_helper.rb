module QuarterlyEvaluationsHelper

  # a user can edit a quarterly evaluation if they are the project manager
  # or if they are a stream supervisor in the project for that stream
  # or an app admin
  def can_edit(quarterly_evaluation, user)
    user.admin? or
    quarterly_evaluation.project.supervisors.where(project_supervisors: { role: 'management' }).include?(user) or
        quarterly_evaluation.project.stream_supervisors.where(project_streams: { ministry: @quarterly_evaluation.ministry }).include?(user)
  end

  def measurables_data(qe)
    meta = {}
    meta[:quarter] = []
    meta[:quarter][0] = qe.quarter
    meta[:first_month], meta[:last_month] = quarter_to_range(meta[:quarter][0])
    meta[:start_month] = Date.new(meta[:first_month][0..3].to_i, meta[:first_month][-2..-1].to_i)
    church_mins = ChurchMinistry.joins(:church_team).
        where(church_teams: {state_language_id: qe.state_language_id}, ministry: qe.ministry)
    ct_outputs = MinistryOutput.
        where(actual: true, church_ministry: church_mins).
        where('month BETWEEN ? AND ?', meta[:first_month], meta[:last_month])
    lang_streams = LanguageStream.where(project: qe.project, state_language_id: qe.state_language_id, ministry: qe.ministry)
    if qe.sub_project.present?
      lang_streams = lang_streams.where(sub_project: qe.sub_project)
    end
    fac_outputs = AggregateMinistryOutput.
        where(actual: true, state_language_id: qe.state_language_id, creator_id: lang_streams.pluck(:facilitator_id)).
        where('month BETWEEN ? AND ?', meta[:first_month], meta[:last_month])
    targets = QuarterlyTarget.joins(:deliverable).where(state_language: qe.state_language, deliverables: { ministry_id: qe.ministry_id }).to_a
    table_data = {}
    qe.ministry.deliverables.active.order(:number).each do |deliverable|
      row = [deliverable.short_form.en]
      case deliverable.reporter
      when 'church_team'
        (0..2).each do |m|
          row << ct_outputs.select{ |o| o.month == m.months.since(meta[:start_month]).strftime('%Y-%m') and o.deliverable_id == deliverable.id }.sum{ |o| o.value }
        end
      when 'facilitator'
        (0..2).each do |m|
          row << fac_outputs.select{ |o| o.month == m.months.since(meta[:start_month]).strftime('%Y-%m') and o.deliverable_id == deliverable.id }.sum{ |o| o.value }
        end
      when 'auto'
        (0..2).each do |m|
          row << auto_actuals(nil, [qe.state_language_id], deliverable, m.months.since(meta[:start_month]).strftime('%Y-%m'), m.months.since(meta[:start_month]).strftime('%Y-%m'))
        end
      else
        row += ['', '', '']
      end
      row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == meta[:quarter][0] }.sum{ |t| t.value }
      if deliverable.sum_of_all?
        row << row[1..3].inject(:+)
      else
        row << row[3]
      end
      (1..3).each do |i|
        meta[:quarter][i] = next_quarter(meta[:quarter][i-1])
        row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == meta[:quarter][i] }.sum{ |t| t.value }
      end
      table_data[deliverable.id] = row
    end
    [table_data, meta]
  end

end
