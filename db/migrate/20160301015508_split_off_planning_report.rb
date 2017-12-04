class SplitOffPlanningReport < ActiveRecord::Migration

  def up
    add_reference :reports, :planning_report, index: true, foreign_key: true
    Report.find_each do |report|
      report.planning_report = PlanningReport.create!(status: report.state)
      report.save!
    end
  end

  def down
    PlanningReport.destroy_all
    remove_column :reports, :planning_report_id
  end

end
