class AddReportApprovedToFacilitatorFeedback < ActiveRecord::Migration
  def change
    add_column :facilitator_feedbacks, :report_approved, :boolean, null: false, default: false
  end
end
