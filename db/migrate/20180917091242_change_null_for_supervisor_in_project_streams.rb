class ChangeNullForSupervisorInProjectStreams < ActiveRecord::Migration
  def change
    change_column_null :project_streams, :supervisor_id, true
  end
end
