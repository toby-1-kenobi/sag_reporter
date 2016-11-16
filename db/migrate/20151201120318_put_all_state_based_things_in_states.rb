class PutAllStateBasedThingsInStates < ActiveRecord::Migration
  def change
    change_column_null :reports, :geo_state_id, false
    change_column_null :impact_reports, :reporter_id, false
    change_column_null :impact_reports, :geo_state_id, false
    change_column_null :mt_resources, :geo_state_id, false
    change_column_null :events, :user_id, false
    change_column_null :events, :geo_state_id, false
    change_column_null :people, :geo_state_id, false
    change_column_null :output_counts, :geo_state_id, false
  end
end
