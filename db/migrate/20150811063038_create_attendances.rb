class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :person, index: true, foreign_key: true, null: false
      t.references :event, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :attendances, [:event_id, :person_id], unique: true
  end
end
