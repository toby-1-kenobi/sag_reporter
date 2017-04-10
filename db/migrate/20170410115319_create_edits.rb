class CreateEdits < ActiveRecord::Migration
  def change
    create_table :edits do |t|
      t.string :table_name, null: false
      t.string :field_name, null: false
      t.integer :record_id, null: false
      t.string :old_value, null: false
      t.string :new_value, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 0, index: true
      t.datetime :curation_date, index: true
      t.datetime :second_curation_date, index: true

      t.timestamps null: false
    end
    add_reference :edits, :curated_by, references: :users, index: true
    add_foreign_key :edits, :users, column: :curated_by_id
    add_index :edits, :created_at
  end
end
