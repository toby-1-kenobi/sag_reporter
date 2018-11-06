class AddReportApprovedToSupervisorFeedbacks < ActiveRecord::Migration
  def change
    add_column :supervisor_feedbacks, :report_approved, :boolean, null: false, default: false
  end
end
