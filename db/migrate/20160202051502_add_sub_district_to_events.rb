class AddSubDistrictToEvents < ActiveRecord::Migration

  def change
    add_reference :events, :sub_district, index: true
    rename_column :events, :district, :district_name
    rename_column :events, :sub_district, :sub_district_name
  end

end
