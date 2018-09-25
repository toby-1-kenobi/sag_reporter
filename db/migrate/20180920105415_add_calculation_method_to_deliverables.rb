class AddCalculationMethodToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :calculation_method, :integer, index: true, null: false, default: 0
    add_column :deliverables, :reporter, :integer, index: true, null: false, default: 0
  end
end
