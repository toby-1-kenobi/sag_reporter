class CreateToolsProductCategoriesJoinTable < ActiveRecord::Migration
  def change
    create_join_table :tools, :product_categories do |t|
      t.index [:tool_id, :product_category_id], unique: true, name: "index_tools_product_categories_on_t_and_pc"
    end
  end
end
