require 'csv'

baseline_year = 2015
baseline_month = 11

file_list = Dir[Rails.root.join('db', 'baseline_data', '**', '*.csv')]

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

# This finds the distance between two strings
# the closer the strings are in comparison, the smaller the distance
# look up Levenshtein Distance on Wikipedia to see how it works
# this code was taken from rosettacode.org and would have been much more fun had I
# written it myself
def levenshtein_distance(a, b)
  a, b = a.downcase, b.downcase
  costs = Array(0..b.length) # i == 0
  (1..a.length).each do |i|
    costs[0], nw = i, i - 1  # j == 0; nw is lev(i-1, j)
    (1..b.length).each do |j|
      costs[j], nw = [costs[j] + 1, costs[j-1] + 1, a[i-1] == b[j-1] ? nw : nw + 1].min, costs[j]
    end
  end
  costs[b.length]
end

def match_progress_marker(description, outcome_area, weight, unmatched_progress_markers, cutoff)
  if ! description or description.empty?
    raise "Missing progress marker"
  end
  haystack_progress_markers = unmatched_progress_markers.select{ |pm| pm.topic == outcome_area and pm.weight = weight }
  if progress_marker = ProgressMarker.find_by_description(description)
    puts "#{outcome_area.name} #{weight} #{progress_marker.name}"
    return progress_marker
  elsif progress_marker = ProgressMarker.find_by_description(description.chomp '.')
    # in case there is a trailing '.' that isn't in the db descriptions
    puts "#{outcome_area.name} #{weight} #{progress_marker.name}"
    return progress_marker
  else
    # go through every progress marker comparing the descriptions
    if haystack_progress_markers.count == 0
      raise "Run out of progress markers to match in #{outcome_area.name} weight #{weight}"
    end
    closest = haystack_progress_markers.pop
    closest_distance = levenshtein_distance closest.description, description
    haystack_progress_markers.each do |pm|
      distance = levenshtein_distance pm.description, description
      if distance < closest_distance
        closest = pm
        closest_distance = distance
      end
    end
    if closest_distance <= cutoff
      puts "#{outcome_area.name} #{weight} #{closest.name}"
      if closest_distance >= 50
        puts "uncertain match (distance: #{closest_distance})"
        puts description
        puts closest.description
        puts ""
      end
      return closest
    else
      return nil
    end
  end
end

def parse_row(row, geo_states, languages, unmatched_progress_markers, pm_distance_cutoff)
  
  outcome_area = Topic.find_by_name row[:outcome_area]
  if !outcome_area
    raise "could not find outcome area: #{row[:outcome_area]}"
  end
  progress_marker = match_progress_marker row[:progress_marker], outcome_area, row[:weight], unmatched_progress_markers, pm_distance_cutoff
  if !progress_marker
    return false
  end
  unmatched_progress_markers.delete progress_marker
  puts "PMs remaining #{unmatched_progress_markers.count}"
  return true
end

def import_from_file(filename)

  file_data = CSV.table(filename, converters: :blank_to_nil)

  # the first row below the headers is the geo_states
  geo_state_data = file_data.delete(0).to_hash
  # the next is the language names
  language_data = file_data.delete(0).to_hash

  # the first 2 cells in each of these rows are not needed
  geo_state_data.slice! 0, 3
  language_data.slice! 0, 3

  # collect together the languages and states for this dataset
  geo_states = Hash.new
  languages = Hash.new
  geo_state_data.each do |key, geo_state_name|
    if geo_state = GeoState.find_by_name(geo_state_name)
      geo_states[key] = geo_state
    else
      raise "Could not find State: #{geo_state_name}"
    end
    if language = Language.find_by_name(language_data[key])
      languages[key] = language
    else
      raise "Could not find language: #{language_sym.to_s}"
    end
    # check that the language is in the state
    if !languages[key].geo_states.include? geo_states[key]
      raise "#{language_data[key]} is not a member of #{geo_state_name}"
    end
  end

  unmatched_progress_markers = ProgressMarker.all.to_a
  unparsed_rows = Array.new
  file_data.each{ |row| unparsed_rows << row }
  cutoff = 0
  unable_to_parse = Array.new
  while unparsed_rows.any?
    unparsed_rows.each do |row|
      begin
        if parse_row(row, geo_states, languages, unmatched_progress_markers, cutoff)
          unparsed_rows.delete(row)
        end
      rescue
        unable_to_parse << unparsed_rows.delete(row)
      end
    end
    cutoff += 10
  end

  if unmatched_progress_markers.count > 0
    puts "unused markers:"
    unmatched_progress_markers.each{ |pm| puts pm.description }
  end

  if unable_to_parse.count > 0
    puts "unable to parse rows:"
    unable_to_parse.each{ |row| puts row[:progress_marker] }
  end

end

file_list.each do |file|
  import_from_file(file)
end
