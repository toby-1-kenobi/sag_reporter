class ChangeMinistryReferenceInSupervisorFeedbacks < ActiveRecord::Migration
  def up
    add_reference :supervisor_feedbacks, :ministry, index: true, foreign_key: true, null: false
    add_reference :supervisor_feedbacks, :supervisor, index: true, null: false, references: :users

    remove_reference :supervisor_feedbacks, :project_stream
  end
  def down
    remove_reference :supervisor_feedbacks, :ministry
    remove_reference :supervisor_feedbacks, :supervisor

    add_reference :supervisor_feedbacks, :project_stream, index: true, foreign_key: true
  end
end
