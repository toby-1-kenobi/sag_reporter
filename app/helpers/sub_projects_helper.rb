module SubProjectsHelper

  def quarterly_summary(project, stream, outputs, aggregate_outputs, state_languages, start_month, targets, quarter)
    table_data = []
    stream.deliverables.active.order(:number).each do |deliverable|
      row = [deliverable.short_form.en]
      case deliverable.reporter
      when 'church_team'
        (0..2).each do |m|
          row << outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id == deliverable.id }.sum{ |o| o.value }
        end
      when 'facilitator'
        (0..2).each do |m|
          row << aggregate_outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id == deliverable.id }.sum{ |o| o.value }
        end
      when 'translation_progress'
        if stream.code == 'TR'

          translation_projects = TranslationProject.where(project: project, language_id: StateLanguage.where(id: state_languages).pluck(:language_id))
          (0..2).each do |m|
            row <<  translation_projects.map{ |tp| tp.count_verses(deliverable, m.months.since(start_month).strftime('%Y-%m')) }.sum
          end
        else
          row += ['0', '0', '0']
        end
      when 'auto'
        (0..2).each do |m|
          row << auto_actuals(nil, state_languages, deliverable, m.months.since(start_month).strftime('%Y-%m'), m.months.since(start_month).strftime('%Y-%m'))
        end
      else
        row += ['', '', '']
      end
      current_quarter = quarter
      row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == current_quarter }.sum{ |t| t.value }
      if deliverable.sum_of_all?
        row << row[1..3].inject(:+)
      else
        row << row[3]
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
