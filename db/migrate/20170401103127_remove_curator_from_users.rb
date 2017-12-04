class RemoveCuratorFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :curator
  end
end
