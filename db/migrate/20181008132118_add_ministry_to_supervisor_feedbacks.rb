class AddMinistryToSupervisorFeedbacks < ActiveRecord::Migration
  def up
    add_reference :supervisor_feedbacks, :project_stream, index: true, foreign_key: true
    remove_reference :supervisor_feedbacks, :supervisor
  end
  def down
    add_reference :supervisor_feedbacks, :supervisor, index: true, null: false
    add_foreign_key :supervisor_feedbacks, :users, column: 'supervisor_id'
    remove_reference :supervisor_feedbacks, :project_stream
  end
end
