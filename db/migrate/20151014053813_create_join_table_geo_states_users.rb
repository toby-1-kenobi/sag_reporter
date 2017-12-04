class CreateJoinTableGeoStatesUsers < ActiveRecord::Migration

  def up
    create_join_table :geo_states, :users do |t|
      t.index [:geo_state_id, :user_id], unique: true
      t.index [:user_id, :geo_state_id]
    end
    execute <<-SQL
      INSERT INTO geo_states_users (geo_state_id, user_id)
      SELECT geo_state_id, id FROM users
      WHERE users.geo_state_id IS NOT NULL
    SQL
    remove_column :users, :geo_state_id
  end

  def down
  	add_reference :users, :geo_state, index: true, foreign_key: true
  	execute <<-SQL
  	  UPDATE users
  	  SET geo_state_id = geo_states_users_one_state.geo_state_id
  	  FROM (
  	  	SELECT DISTINCT ON (user_id) user_id, geo_states_users.geo_state_id
  	  	FROM geo_states_users
  	  ) AS geo_states_users_one_state
      WHERE users.id = geo_states_users_one_state.user_id
  	SQL
  	drop_table :geo_states_users
  end
  
end
