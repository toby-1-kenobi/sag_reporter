class ChangeEventLocationData < ActiveRecord::Migration
  def change
  	remove_column :events, :location
  	add_column :events, :district, :string, index: true
  	add_column :events, :sub_district, :string, index: true
  	add_column :events, :village, :string, index: true
  end
end
