class AddUserTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_type, :integer, null: true, index: true
  end
end
