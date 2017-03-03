class DropPermissions < ActiveRecord::Migration

  def up
    drop_join_table :permissions, :roles
    drop_table :permissions
  end

  def down
    create_table :permissions do |t|
      t.string   :name
      t.string   :description
      t.integer  :category
      t.timestamps
    end
    add_index :permissions, :name
    create_join_table :permissions, :roles do |t|

    end
  end
end
