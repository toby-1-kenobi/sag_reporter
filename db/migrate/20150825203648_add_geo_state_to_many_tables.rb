class AddGeoStateToManyTables < ActiveRecord::Migration
  def change
    add_reference :mt_resources, :geo_state, index: true, foreign_key: true
    add_reference :reports, :geo_state, index: true, foreign_key: true
    add_reference :impact_reports, :geo_state, index: true, foreign_key: true
    add_reference :events, :geo_state, index: true, foreign_key: true
    add_reference :people, :geo_state, index: true, foreign_key: true
    add_reference :output_counts, :geo_state, index: true, foreign_key: true
    add_reference :progress_updates, :geo_state, index: true, foreign_key: true
  end
end
