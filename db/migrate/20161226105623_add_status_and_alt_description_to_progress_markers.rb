class AddStatusAndAltDescriptionToProgressMarkers < ActiveRecord::Migration
  def change
    add_column :progress_markers, :status, :integer, null: false, default: 0
    add_column :progress_markers, :alternate_description, :text
    add_index :progress_markers, :status
  end
end
