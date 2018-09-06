class EnforceUniqueNumbers < ActiveRecord::Migration
  def change
    change_column :ministries, :number, :integer, null: false, index: true, unique: true
    change_column :deliverables, :number, :integer, null: false, index: true, unique: true
    change_column :product_categories, :number, :integer, null: false, index: true, unique: true
    change_column :progress_markers, :number, :integer, index: true, unique: true
  end
end
