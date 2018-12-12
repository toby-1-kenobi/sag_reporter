class AddNameToProductCategories < ActiveRecord::Migration
  def up
    add_reference :product_categories, :name, index: true, null: false
    add_foreign_key :product_categories, :translation_codes, column: :name_id
  end
  def down
    remove_reference :product_categories, :name_id
  end
end
