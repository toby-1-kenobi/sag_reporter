class AddUniqueIndexOnQuarterlyTargets < ActiveRecord::Migration
  def change
    add_index :quarterly_targets, [:state_language_id, :deliverable_id, :quarter], unique: true, name: 'index_language_deliverable_quarter'
  end
end
