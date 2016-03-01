class TieInImpactReport < ActiveRecord::Migration

  def up
    add_reference :reports, :impact_report, index: true, foreign_key: true
    ImpactReport.find_each do |ir|
      Report.create!(content: ir.content,
        reporter_id: ir.reporter_id,
        event_id: ir.event_id,
        geo_state_id: ir.geo_state_id,
        report_date: ir.report_date,
        state: ir.state,
        mt_society: ir.mt_society,
        mt_church: ir.mt_church,
        needs_society: ir.needs_society,
        needs_church: ir.needs_church,
        impact_report_id: ir.id)
    end
  end

  def down
    Report.destroy_all("impact_report_id IS NOT NULL")
    remove_column :reports, :impact_report_id
  end

end
