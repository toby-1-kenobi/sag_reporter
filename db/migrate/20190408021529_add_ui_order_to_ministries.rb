class AddUiOrderToMinistries < ActiveRecord::Migration
  def change
    add_column :ministries, :ui_order, :integer
  end
end
