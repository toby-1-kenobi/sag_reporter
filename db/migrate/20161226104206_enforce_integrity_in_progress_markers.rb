class EnforceIntegrityInProgressMarkers < ActiveRecord::Migration
  def change
    change_column_null :progress_markers, :name, :false
    change_column_null :progress_markers, :description, :false
    change_column_null :progress_markers, :topic_id, :false
  end
end
