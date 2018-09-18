class CreateSupervisorFeedbacks < ActiveRecord::Migration
  def change
    create_table :supervisor_feedbacks do |t|
      t.references :supervisor, index: true, null: false
      t.references :facilitator, index: true, null: false
      t.string :month, null: false
      t.text :plan_feedback
      t.text :plan_response
      t.text :result_feedback
      t.integer :facilitator_progress
      t.integer :project_progress

      t.timestamps null: false
    end
    add_foreign_key :supervisor_feedbacks, :users, column: 'supervisor_id'
    add_foreign_key :supervisor_feedbacks, :users, column: 'facilitator_id'
  end
end
