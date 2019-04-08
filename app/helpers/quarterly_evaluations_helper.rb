module QuarterlyEvaluationsHelper

  # a user can edit a quarterly evaluation if they are the project manager
  # or if they are a stream supervisor in the project for that stream
  # or an app admin
  def can_edit(quarterly_evaluation, user)
    user.admin? or
    quarterly_evaluation.project.supervisors.where(project_supervisors: { role: 'management' }).include?(user) or
        quarterly_evaluation.project.stream_supervisors.where(project_streams: { ministry: @quarterly_evaluation.ministry }).include?(user)
  end

  def measurables_data(qe, translation_project = nil)
    meta = {}
    meta[:quarter] = {}
    meta[:quarter][0] = qe.quarter
    meta[:quarter][-1] = previous_quarter(meta[:quarter][0])
    meta[:quarter][-2] = previous_quarter(meta[:quarter][-1])
    meta[:first_month] = quarter_to_range(meta[:quarter][-2])[0]
    meta[:last_month] = quarter_to_range(meta[:quarter][0])[1]
    meta[:start_month] = Date.new(meta[:first_month][0..3].to_i, meta[:first_month][-2..-1].to_i)
    church_mins = ChurchMinistry.joins(:church_team).
        where(church_teams: { status: 0, state_language_id: qe.state_language_id }, ministry: qe.ministry).pluck :id
    ct_outputs = MinistryOutput.
        where(actual: true, church_ministry_id: church_mins).
        where('month BETWEEN ? AND ?', meta[:first_month], meta[:last_month]).
        pluck_to_struct(:month, :deliverable_id, :value)
    lang_streams = LanguageStream.where(project: qe.project, state_language_id: qe.state_language_id, ministry: qe.ministry)
    if qe.sub_project.present?
      lang_streams = lang_streams.where(sub_project: qe.sub_project)
    end
    fac_outputs = AggregateMinistryOutput.
        where(actual: true, state_language_id: qe.state_language_id, creator_id: lang_streams.pluck(:facilitator_id)).
        where('month BETWEEN ? AND ?', meta[:first_month], meta[:last_month]).
        pluck_to_struct(:month, :deliverable_id, :value)
    targets = QuarterlyTarget.joins(:deliverable).where(state_language: qe.state_language, deliverables: { ministry_id: qe.ministry_id }).
        pluck_to_struct(:deliverable_id, :quarter, :value)
    table_data = {}
    calculations = {
        'church_team' => lambda{ |m, d| ct_outputs.select{ |o| o.month == m.months.since(meta[:start_month]).strftime('%Y-%m') and o.deliverable_id == d.id }.sum{ |o| o.value } },
        'facilitator' => lambda{ |m, d| fac_outputs.select{ |o| o.month == m.months.since(meta[:start_month]).strftime('%Y-%m') and o.deliverable_id == d.id }.sum{ |o| o.value } },
        'translation_progress' => lambda{ |m, d| translation_project ? translation_project.count_verses(d, m.months.since(meta[:start_month]).strftime('%Y-%m')) : '0' },
        'auto' => lambda { |m, d| auto_actuals(nil, [qe.state_language_id], d, m.months.since(meta[:start_month]).strftime('%Y-%m'), m.months.since(meta[:start_month]).strftime('%Y-%m')) }
    }
    qe.ministry.deliverables.active.order(:ui_order).each do |deliverable|
      row = [deliverable.short_form.en]
      monthly_actuals = []
      if calculations[deliverable.reporter]
        (0..8).each do |m|
          monthly_actuals << calculations[deliverable.reporter].call(m, deliverable)
        end
      else
        Rails.logger.warn "unknown type for deliverable #{deliverable.id} - #{deliverable.reporter}"
        monthly_actuals += Array.new(9){ '' }
      end
      (-2..-1).each do |q|
        row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == meta[:quarter][q] }.sum{ |t| t.value }
        q_actuals = monthly_actuals.shift(3)
        if deliverable.sum_of_all?
          row << q_actuals.inject(:+)
        else
          row << q_actuals.last
        end
      end
      row += monthly_actuals
      row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == meta[:quarter][0] }.sum{ |t| t.value }
      if deliverable.sum_of_all?
        row << monthly_actuals.inject(:+)
      else
        row << monthly_actuals.last
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
