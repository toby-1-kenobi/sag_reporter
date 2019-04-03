module SubProjectsHelper

  def quarterly_summary(project, stream, ct_outputs, fac_outputs, state_languages, start_month, targets, quarters)
    table_data = []
    calculations = {
        'church_team' => lambda{ |m, d| ct_outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id == d.id }.sum{ |o| o.value } },
        'facilitator' => lambda{ |m, d| fac_outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id == d.id }.sum{ |o| o.value } },
        'translation_progress' => lambda do |m, d|
          if stream.code == 'TR'
            translation_projects = TranslationProject.where(project: project, language_id: StateLanguage.where(id: state_languages).pluck(:language_id))
            translation_projects.map{ |tp| tp.count_verses(d, m.months.since(start_month).strftime('%Y-%m')) }.sum
          else
            '0'
          end
        end,
        'auto' => lambda { |m, d| auto_actuals(nil, state_languages, d, m.months.since(start_month).strftime('%Y-%m'), m.months.since(start_month).strftime('%Y-%m')) }
    }
    stream.deliverables.active.order(:number).each do |deliverable|
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
      (0..1).each do |i|
        row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == quarters[i] }.sum{ |t| t.value }
        q_actuals = monthly_actuals.shift(3)
        if deliverable.sum_of_all?
          row << q_actuals.inject(:+)
        else
          row << q_actuals.last
        end
      end
      row += monthly_actuals
      current_quarter = quarters.last
      row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == current_quarter }.sum{ |t| t.value }
      if deliverable.sum_of_all?
        row << monthly_actuals.inject(:+)
      else
        row << monthly_actuals.last
      end
      3.times do
        current_quarter = next_quarter(current_quarter)
        row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == current_quarter }.sum{ |t| t.value }
      end
      table_data << row
    end
    table_data
  end

end
