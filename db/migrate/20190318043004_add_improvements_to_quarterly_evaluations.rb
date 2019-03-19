class AddImprovementsToQuarterlyEvaluations < ActiveRecord::Migration
  def change
    add_column :quarterly_evaluations, :improvements, :text
  end
end
