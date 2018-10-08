class ChangeNullForProjectStreamInSupervisorFeedbacks < ActiveRecord::Migration
  def change
    change_column_null :supervisor_feedbacks, :project_stream_id, false
  end
end
