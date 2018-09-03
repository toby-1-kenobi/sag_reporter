class RenameRegistrationCuratorInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :registration_curator, :zone_admin
  end
end
