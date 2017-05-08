class CreateEditsGeoStatesJoinTable < ActiveRecord::Migration
  def change
    create_join_table :edits, :geo_states do |t|
      t.index [:edit_id, :geo_state_id], unique: true
    end
  end
end
