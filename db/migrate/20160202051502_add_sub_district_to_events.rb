class AddSubDistrictToEvents < ActiveRecord::Migration

  def change
    add_reference :events, :sub_district, index: true
    rename_column :events, :district, :district_dep
    rename_column :events, :sub_district, :sub_district_dep
  end

end
