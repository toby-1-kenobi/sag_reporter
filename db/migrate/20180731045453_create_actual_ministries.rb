class CreateActualMinistries < ActiveRecord::Migration
  def change
    create_table :actual_ministries do |t|
      t.integer :year, null: false, index: true
      t.integer :month, null: false, index: true
      t.integer :value, null: false
      t.references :church_congregation, index: true, foreign_key: true, null: false
      t.references :ministry_marker, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
