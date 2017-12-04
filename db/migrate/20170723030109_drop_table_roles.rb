class DropTableRoles < ActiveRecord::Migration
  def change
    drop_table :roles
    remove_column :users, :role_id
  end
end
