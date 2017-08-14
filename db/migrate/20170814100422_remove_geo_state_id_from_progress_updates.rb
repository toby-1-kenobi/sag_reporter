class RemoveGeoStateIdFromProgressUpdates < ActiveRecord::Migration
  def change
    remove_column :progress_updates, :geo_state_id
  end
end
