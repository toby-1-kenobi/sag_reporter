class AddNumberIndexToFinishLineMarkers < ActiveRecord::Migration
  def change
    add_index :finish_line_markers, :number
  end
end
