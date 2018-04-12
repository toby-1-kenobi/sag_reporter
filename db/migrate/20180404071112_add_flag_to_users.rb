class AddFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_password, :boolean, default: false, presence: true
  end
end
