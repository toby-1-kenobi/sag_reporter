class CreateQuarterlyTargets < ActiveRecord::Migration
  def change
    create_table :quarterly_targets do |t|
      t.references :state_language, index: true, foreign_key: true, null: false
      t.references :deliverable, index: true, foreign_key: true, null: false
      t.string :quarter, null: false
      t.integer :value, null: false

      t.timestamps null: false
    end
  end
end
