class CreateJoinTableMtResourcesCategories < ActiveRecord::Migration
  def change
    create_join_table :mt_resources, :product_categories do |t|
      t.index [:mt_resource_id, :product_category_id], unique: true, name: 'index_resource_category'
    end
  end
end
