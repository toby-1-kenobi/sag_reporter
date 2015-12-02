
class AddDateToReport < ActiveRecord::Migration
  def up
    add_column :reports, :report_date, :date
    add_column :impact_reports, :report_date, :date
    Report.all.each do |report|
      report.report_date = report.event ? report.event.event_date : report.created_at.to_date
      report.save!
    end
    ImpactReport.all.each do |report|
      report.report_date = report.event ? report.event.event_date : report.created_at.to_date
      report.save!
    end
    change_column_null :reports, :report_date, false
    change_column_null :impact_reports, :report_date, false
  end
  def down
    remove_column :reports, :report_date
    remove_column :impact_reports, :report_date
  end
end