class CreatePlanningReports < ActiveRecord::Migration
  def change
    create_table :planning_reports do |t|
      t.integer :status, null: false, default: 1
      t.timestamps null: false
    end
  end
end
