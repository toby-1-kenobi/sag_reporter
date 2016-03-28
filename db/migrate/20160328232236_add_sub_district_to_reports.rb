class AddSubDistrictToReports < ActiveRecord::Migration
  def change
    add_reference :reports, :sub_district, index: true, foreign_key: true
    add_column :reports, :location, :string
  end
end
