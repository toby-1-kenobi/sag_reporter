class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :geo_states, :languages do |t|
       t.index [:geo_state_id, :language_id], unique: true
    end
  end
end
