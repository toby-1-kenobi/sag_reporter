class CreateJoinTableEventLanguage < ActiveRecord::Migration
  def change
    create_join_table :events, :languages do |t|
      # t.index [:event_id, :language_id]
      # t.index [:language_id, :event_id]
    end
    add_index :events_languages, [:event_id, :language_id], unique: true, name: 'index_events_languages'
  end
end
