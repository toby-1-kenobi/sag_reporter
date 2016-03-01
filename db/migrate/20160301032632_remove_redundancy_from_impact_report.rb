class RemoveRedundancyFromImpactReport < ActiveRecord::Migration

  def up
    remove_column :impact_reports, :content
    remove_column :impact_reports, :reporter_id
    remove_column :impact_reports, :event_id
    remove_column :impact_reports, :geo_state_id
    remove_column :impact_reports, :report_date
    remove_column :impact_reports, :mt_society
    remove_column :impact_reports, :mt_church
    remove_column :impact_reports, :needs_society
    remove_column :impact_reports, :needs_church
  end

  def down
    add_column :impact_reports, :content, :text
    add_reference :impact_reports, :reporter, references: :users, index: true
    add_reference :impact_reports, :event, index: true, foreign_key: true
    add_reference :impact_reports, :geo_state, index: true, foreign_key: true
    add_column :impact_reports, :report_date, :date
    add_column :impact_reports, :mt_society, :boolean
    add_column :impact_reports, :mt_church, :boolean
    add_column :impact_reports, :needs_society, :boolean
    add_column :impact_reports, :needs_church, :boolean
    add_foreign_key :impact_reports, :users, column: :reporter_id
    Report.where.not(impact_report: nil).find_each do |report|
      ir = report.impact_report
      ir.content = report.content
      ir.reporter_id = report.reporter_id
      ir.event_id = report.event_id
      ir.geo_state_id = report.geo_state_id
      ir.report_date = report.report_date
      ir.mt_society = report.mt_society
      ir.mt_church = report.mt_church
      ir.needs_society = report.needs_society
      ir.needs_church = report.needs_church
      ir.save!
    end
    change_column_null :impact_reports, :content, false
    change_column_null :impact_reports, :reporter_id, false
    change_column_null :impact_reports, :geo_state_id, false
    change_column_null :impact_reports, :report_date, false
  end
end
