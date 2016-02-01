baseline_year = 2015
baseline_month = 11

puts "Count the progress updates of #{baseline_year}-#{baseline_month} for all minority languages in the db"

zones = Zone.all
states = GeoState.includes(:languages).all
lps = LanguageProgress.includes(:progress_updates).where('progress_updates.year' => baseline_year, 'progress_updates.month' => baseline_month)

zones.each do |zone|
  puts ""
  puts zone.name
  states.select{ |s| s.zone_id == zone.id }.each do |state|
    puts "  " + state.name
    state.languages.select{ |l| !l.lwc }.each do |lang|
      update_count = 0
      lps.select{ |lp| lp.language_id == lang.id }.each do |lp|
        update_count += lp.progress_updates.select{ |pu| pu.geo_state_id == state.id }.count
      end
      puts "    #{lang.name} #{update_count}"
    end
  end
end