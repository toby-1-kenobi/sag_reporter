class CreateRolesPermissions < ActiveRecord::Migration
  def change
    create_table :roles_permissions do |t|
      t.integer :role_id
      t.integer :permission_id

      t.timestamps null: false
    end
    add_index :roles_permissions, :role_id
    add_index :roles_permissions, :permission_id
    add_index :roles_permissions, [:role_id, :permission_id], unique: true
  end
end
