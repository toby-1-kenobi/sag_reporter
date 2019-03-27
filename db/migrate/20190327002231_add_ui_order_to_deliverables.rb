class AddUiOrderToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :ui_order, :integer, index: true
  end
end
