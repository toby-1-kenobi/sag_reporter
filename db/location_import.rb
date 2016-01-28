require 'csv'

destroy_existing_data = true

district_file = Rails.root.join('db', 'location_data', 'India_State_District_LocationFile.csv')
sub_district_file = Rails.root.join('db', 'location_data', 'India_District_SubDistrict_LocationFile.csv')

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

geo_state_lookup = Hash.new
districts = Hash.new
sub_districts = Hash.new

puts "importing district data from #{district_file}"
district_data = CSV.table(district_file, converters: :blank_to_nil)

def parse_district_row(row, geo_state_lookup, districts)
  geo_state_lookup[row[:statename]] ||= GeoState.find_by_name row[:statename]
  if !geo_state_lookup[row[:statename]]
    puts "Can't find state #{row[:statename]} so not adding district #{row[:districtname]}"
    return false
  end
  district = District.new(name: row[:districtname], geo_state: geo_state_lookup[row[:statename]])
  if district.valid?
    districts[row[:districtname]] = district
    return true
  else
    puts "not adding district #{row[:districtname]} because it fails validity checks."
    return false
  end
end

district_data.each{ |row| parse_district_row(row, geo_state_lookup, districts) }


puts "importing sub-district data from #{sub_district_file}"
sub_district_data = CSV.table(sub_district_file, converters: :blank_to_nil)

def parse_sub_district_row(row, districts, sub_districts)
  if !districts[row[:districtname]]
    puts "Can't find district #{row[:districtname]} so not adding sub-district #{row[:subdistrictname]}"
    return false
  end
  sub_district = SubDistrict.new(name: row[:subdistrictname], district: districts[row[:districtname]])
  if sub_district.valid?
    sub_districts[row[:subdistrictname]] = sub_district
  else
    puts "not adding sub-district #{row[:subdistrictname]} because it fails validity checks."
  end
end

sub_district_data.each{ |row| parse_sub_district_row(row, districts, sub_districts) }

puts ""
puts "#{districts.count} valid districts and #{sub_districts.count} valid sub-districts have been made."
puts "Do you want to add them to the database?"
if destroy_existing_data
  puts "answering yes will destroy the current district and sub-district data!"
end
print "Y/n: "
response = gets.chars.first

if response == 'Y' || response == 'y'
  puts "please be patient while the database is updated. It may take a few minutes."
  if destroy_existing_data
    puts "destroying exisitng districs and sub-districts."
    District.destroy_all
  end
  puts "Saving new districts"
  districts.values.each{ |d| d.save }
  puts "Saving new sub-districts"
  sub_districts.values.each{ |sd| sd.save }
  puts "Done!"
  puts "There are now #{District.count} districts and #{SubDistrict.count} sub-districts in the database."
else
  puts "import canceled"
end