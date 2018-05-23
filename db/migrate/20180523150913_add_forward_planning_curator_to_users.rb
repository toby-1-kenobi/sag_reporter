class AddForwardPlanningCuratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forward_planning_curator, :boolean, null: false, default: false
  end
end
