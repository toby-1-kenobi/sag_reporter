class AddNumberColumns < ActiveRecord::Migration
  def change
    add_column :deliverables, :number, :integer
    add_column :ministries, :number, :integer
    add_column :product_categories, :number, :integer
    remove_column :deliverables, :name, :string, index: true, null: false
    remove_column :deliverables, :description, :text
    remove_column :ministries, :name, :string, index: true, null: false
    remove_column :ministries, :description, :text
    remove_column :product_categories, :name, :string, index: true, null: false
  end
end
