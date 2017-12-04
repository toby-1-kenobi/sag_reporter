class AddWeightToProgressMarkers < ActiveRecord::Migration
  def change
    add_column :progress_markers, :weight, :integer, default: 1, null: false
  end
end
