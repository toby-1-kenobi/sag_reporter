class AddPmDescriptionTypeToZones < ActiveRecord::Migration
  def change
    add_column :zones, :pm_description_type, :integer, null: false, default: 0
    add_index :zones, :pm_description_type
  end
end
