module SubProjectsHelper

  def quarterly_summary(stream, outputs, aggregate_outputs, start_month, targets, quarter)
    table_data = []
    stream.deliverables.active.order(:number).each do |deliverable|
      row = [deliverable.short_form.en]
      case deliverable.reporter
      when 'church_team'
        (0..2).each do |m|
          row << outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id = deliverable.id }.sum{ |o| o.value }
        end
      when 'facilitator'
        (0..2).each do |m|
          row << aggregate_outputs.select{ |o| o.month == m.months.since(start_month).strftime('%Y-%m') and o.deliverable_id = deliverable.id }.sum{ |o| o.value }
        end
      end
      row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == quarter }.sum{ |t| t.value }
      if deliverable.sum_of_all?
        row << row[1..3].inject(:+)
      else
        row << row[3]
      end
      3.times do
        quarter = next_quarter(quarter)
        row << targets.select{ |t| t.deliverable_id == deliverable.id and t.quarter == quarter }.sum{ |t| t.value }
      end
      table_data << row
    end
    table_data
  end

end
