class AddRegistrationCuratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_curator, :boolean, null: false, default: false, index: true
  end
end
