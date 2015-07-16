class AddMotherTongueIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mother_tongue_id, :integer
    add_index :users, :mother_tongue_id
  end
end
