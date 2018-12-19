class DropTableEvents < ActiveRecord::Migration
  def change
    remove_reference :reports, :event, index: true, foreign_key: true
    drop_join_table :events, :languages do |t|
      t.index [:event_id, :language_id], unique: true, name: 'index_events_languages'
    end
    drop_table :events do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :event_label, null: false
      t.date :event_date, index: true, null: false
      t.integer :participant_amount
      t.integer :purpose
      t.text :content
      t.timestamps null: false
      t.string :district_name, index: true
      t.string :sub_district_name, index: true
      t.string :village, index: true
      t.references :geo_state, index: true, foreign_key: true, null: false
      t.references :sub_district, index: true, foreign_key: true
    end
  end
end
