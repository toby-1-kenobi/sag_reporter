
init_count = SubDistrict.count
print "There are #{init_count} sub-districts in the database. What percentage do you want to destroy? "
percent = gets.chomp.to_f./100

puts "Will destroy approximately #{(init_count * percent).to_i} sub-district objects evenly across districts."
print 'Do you want to continue? [Y/n] '
response = gets.chomp
case
  when response.match(/^[y|Y].*/), response.blank?
    District.includes({:sub_districts => :reports}, :geo_state).find_each do |district|
      print "#{district.geo_state.name}, #{district.name}: "
      subs = district.sub_districts.to_a.sort_by{ |sd| sd.reports.count }.reverse
      amount_to_destroy = (district.sub_districts.count * percent).to_i
      puts "\tdestroying #{amount_to_destroy} of #{subs.count}"
      subs.slice(0, amount_to_destroy).each{ |sd| sd.destroy }
    end
  else
    puts 'canceled'
end
final_count = SubDistrict.count
puts "destroyed #{init_count - final_count} sub-districts. #{final_count} subdistricts remaining."