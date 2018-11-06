class AddAppVersionToExternalDevices < ActiveRecord::Migration
  def change
    add_column :external_devices, :app_version, :string, null: true
  end
end
