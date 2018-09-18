class ExtendFacilitatorFeedback < ActiveRecord::Migration
  def change
    rename_column :facilitator_feedbacks, :feedback, :plan_feedback
    change_column_null :facilitator_feedbacks, :plan_feedback, true
    rename_column :facilitator_feedbacks, :response, :plan_response
    rename_column :facilitator_feedbacks, :team_member_id, :plan_team_member_id
    add_column :facilitator_feedbacks, :result_feedback, :text, null: true
    add_column :facilitator_feedbacks, :result_response, :text, null: true
    add_reference :facilitator_feedbacks, :result_team_member, index: true, null: true
    add_foreign_key :facilitator_feedbacks, :users, column: :result_team_member_id
    add_column :facilitator_feedbacks, :progress, :integer, null: true
  end
end
