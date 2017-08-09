class CreateExternalDevices < ActiveRecord::Migration
  def change
    create_table :external_devices do |t|
      t.string :device_id
      t.string :name
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
