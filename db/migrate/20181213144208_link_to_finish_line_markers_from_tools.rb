class LinkToFinishLineMarkersFromTools < ActiveRecord::Migration
  def up
    add_reference :tools, :finish_line_marker, index: true, foreign_key: true
  end
  def down
    remove_reference :tools, :finish_line_marker
  end
end
