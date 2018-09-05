class RenameMinistryMarkerToDeliverable < ActiveRecord::Migration
  def change
    rename_table :ministry_markers, :deliverables
    rename_column :ministry_outputs, :ministry_marker_id, :deliverable_id
  end
end
