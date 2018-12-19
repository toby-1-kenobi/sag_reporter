class DropTablePurposes < ActiveRecord::Migration
  def up
    drop_table :events_purposes
    drop_table :purposes
  end
  def down
    create_table :purposes do |t|
      t.string :name, null: false
      t.string :description, null: false

      t.timestamps null: false
    end
    create_table :events_purposes, id: false do |t|
      t.references :event, index: true, foreign_key: true
      t.references :purpose, index: true, foreign_key: true
    end
    add_index :events_purposes, [:event_id, :purpose_id], unique: true
  end
end
