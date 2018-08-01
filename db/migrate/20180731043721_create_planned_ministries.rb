class CreatePlannedMinistries < ActiveRecord::Migration
  def change
    create_table :planned_ministries do |t|
      t.integer :year, index: true, null: false
      t.integer :month, index: true, null: false
      t.integer :value, null: false
      t.references :church_congregation, index: true, foreign_key: true, null: false
      t.references :ministry_marker, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
