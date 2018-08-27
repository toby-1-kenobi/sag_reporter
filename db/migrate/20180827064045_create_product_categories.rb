class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
    add_index :product_categories, :name, unique: true
  end
end
