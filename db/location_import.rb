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
  districts[row[:districtid]] = district
  return true
end

district_data.each{ |row| parse_district_row(row, geo_state_lookup, districts) }


puts "importing sub-district data from #{sub_district_file}"
sub_district_data = CSV.table(sub_district_file, converters: :blank_to_nil)

def parse_sub_district_row(row, districts, sub_districts)
  if !districts[row[:districtid]]
    puts "Can't find district #{row[:districtname]} so not adding sub-district #{row[:subdistrictname]}"
    return false
  end
  sub_district = SubDistrict.new(name: row[:subdistrictname], district: districts[row[:districtid]])
  sub_districts[row[:subdistrictid]] = sub_district
  return true
end

sub_district_data.each{ |row| parse_sub_district_row(row, districts, sub_districts) }

puts ""
puts "#{districts.count} valid districts and #{sub_districts.count} valid sub-districts have been made."
puts "Do you want to add them to the database?"
if destroy_existing_data
  puts "answering yes will destroy the current #{District.count} districts and #{SubDistrict.count} sub-districts already in the database"
end
print "[Y/n] "
response = gets.chars.first

if response == 'Y' || response == 'y'
  puts "please be patient while the database is updated. It may take a few minutes."
  if destroy_existing_data
    puts "destroying existing districts and sub-districts."
    District.destroy_all
  end
  puts "Saving new districts"
  districts.values.each do |d|
    if !d.save
      puts "could not save district #{d.name}"
      d.errors.each{ |error| puts error }
    end
  end
  puts "Saving new sub-districts"
  sub_districts.values.each do |sd|
    if !sd.save
      puts "could not save sub-district #{sd.name}"
      sd.errors.each{ |error| puts error }
    end
  end
  puts "Done!"
  puts "There are now #{District.count} districts and #{SubDistrict.count} sub-districts in the database."
else
  puts "import canceled"
end