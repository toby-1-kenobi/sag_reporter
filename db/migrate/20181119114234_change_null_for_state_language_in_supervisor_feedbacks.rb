class ChangeNullForStateLanguageInSupervisorFeedbacks < ActiveRecord::Migration
  def up
    change_column_null :supervisor_feedbacks, :state_language_id, false
  end
  def down
    change_column_null :supervisor_feedbacks, :state_language_id, true
  end
end
