class AddSubDistrictToEvents < ActiveRecord::Migration

  def up
    add_reference :events, :sub_district, index: true
    Event.where.not(sub_district: '').each do |event|
      district = event.geo_state.find_by_name event.district
      if district
        event.sub_district_id = district.find_by_name event.sub_district
        event.save or fail "could not save event #{event.id}"
      end
    end
    remove_column :events, :district
    remove_column :events, :sub_district
  end

  def down
    add_column :events, :sub_district, :string
    add_column :events, :district, :string
    Event.where.not(sub_district_id: nil).each do |event|
      sd = SubDistrict.find event.sub_district_id
      event.sub_district = sd.name
      event.district = sd.district.name
      event.save or fail "could not save event #{event.id}"
    end
    remove_column :events, :sub_district_id
  end

end
