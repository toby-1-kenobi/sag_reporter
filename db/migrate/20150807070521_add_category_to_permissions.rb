class AddCategoryToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :category, :integer
  end
end
