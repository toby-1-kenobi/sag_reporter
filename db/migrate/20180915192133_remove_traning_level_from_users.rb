class RemoveTraningLevelFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :training_level, :integer
    remove_column :users, :user_type, :integer
  end
end
