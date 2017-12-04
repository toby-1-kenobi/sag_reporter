class AddNumberToProgressMarkers < ActiveRecord::Migration
  def change
    add_column :progress_markers, :number, :integer, null: true
    add_index :progress_markers, :number
  end
end
