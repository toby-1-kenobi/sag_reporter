class DropAggregateDeliverablesAndQuarterlyTargets < ActiveRecord::Migration
  def up
    add_reference :aggregate_ministry_outputs, :deliverable, index: true, foreign_key: true, null: false
    remove_reference :aggregate_ministry_outputs, :aggregate_deliverable
    drop_table :aggregate_quarterly_targets
    drop_table :aggregate_deliverables
  end
  def down
    create_table :aggregate_deliverables do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.integer :number, null: false

      t.timestamps null: false
    end
    create_table :aggregate_quarterly_targets do |t|
      t.references :state_language, index: true, foreign_key: true, null: false
      t.references :aggregate_deliverable, index: true, foreign_key: true, null: false
      t.string :quarter, null: false
      t.integer :value, null: false

      t.timestamps null: false
    end
    add_reference :aggregate_ministry_outputs, :aggregate_deliverable, index: true, foreign_key: true, null: false
    remove_reference :aggregate_ministry_outputs, :deliverable
  end
end
