class AddRegistrationStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_status, :integer, null:false, default: 2
  end
end
