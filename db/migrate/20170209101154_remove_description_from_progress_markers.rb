class RemoveDescriptionFromProgressMarkers < ActiveRecord::Migration
  def change
    remove_column :progress_markers, :description
  end
end
