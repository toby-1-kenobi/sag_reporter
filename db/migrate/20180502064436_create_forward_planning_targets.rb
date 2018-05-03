class CreateForwardPlanningTargets < ActiveRecord::Migration
  def change
    create_table :forward_planning_targets do |t|
      t.integer :topic_id, null: false
      t.integer :state_language_id, null: false
      t.integer :year
      t.integer :targets, null: false, default: 0
      t.timestamps null: false
    end
    add_index :forward_planning_targets, [:topic_id, :state_language_id, :year], unique: true, name: 'index_forward_planning_targets'
  end
end
