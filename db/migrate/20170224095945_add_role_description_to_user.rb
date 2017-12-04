class AddRoleDescriptionToUser < ActiveRecord::Migration
  def change
    add_column :users, :role_description, :string
  end
end
