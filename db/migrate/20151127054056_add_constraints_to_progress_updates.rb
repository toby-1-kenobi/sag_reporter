class AddConstraintsToProgressUpdates < ActiveRecord::Migration
  def change
    change_column_null :progress_updates, :progress, false
    change_column_null :progress_updates, :geo_state_id, false
  end
end
