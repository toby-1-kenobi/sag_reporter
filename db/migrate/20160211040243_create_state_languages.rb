class CreateStateLanguages < ActiveRecord::Migration

  def up
    create_table :state_languages do |t|
      t.references :geo_state, index: true, foreign_key: true
      t.references :language, index: true, foreign_key: true
      t.boolean :project, null: false, default: false

      t.timestamps null: false
    end
    execute "INSERT INTO state_languages (geo_state_id, language_id, created_at, updated_at) SELECT geo_state_id, language_id, now(), now() FROM geo_states_languages;"
    drop_table :geo_states_languages
  end

  def down
    create_join_table :geo_states, :languages do |t|
       t.index [:geo_state_id, :language_id], unique: true
    end
    execute "INSERT INTO geo_states_languages (geo_state_id, language_id) SELECT geo_state_id, language_id FROM state_languages;"
    drop_table :state_languages
  end
end
