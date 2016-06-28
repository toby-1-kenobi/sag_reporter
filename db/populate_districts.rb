# find each district that has no sub-districts related to it
# for each add a sub-district that has the same name as the district

count = 0
District.includes(:sub_districts).where( :sub_districts => { :id => nil } ).find_each do |district|
  puts district.name
  if district.sub_districts.create(name: district.name)
    count += 1
  else
    puts "unable to create sub-district for #{district.name}"
  end
end
puts "#{count} sub-districts added"