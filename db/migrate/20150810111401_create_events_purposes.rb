class CreateEventsPurposes < ActiveRecord::Migration
  def change
    create_table :events_purposes, id: false do |t|
      t.references :event, index: true, foreign_key: true
      t.references :purpose, index: true, foreign_key: true
    end
    add_index :events_purposes, [:event_id, :purpose_id], unique: true
  end
end
