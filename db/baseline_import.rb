require 'csv'

$baseline_year = 2015
$baseline_month = 11

# The data needs to be inserted under an existing user
# use the user called "Toby Anderson" and if he doesn't exist take the first admin user
$user = User.find_by_name "Toby Anderson"
if !$user
  admin_role = Role.find_by_name "admin"
  $user = User.where(role: admin_role).take
end

file_list = Dir[Rails.root.join('db', 'baseline_data', '**', '*.csv')]

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

# This finds the distance between two strings
# the closer the strings are in comparison, the smaller the distance
# look up Levenshtein Distance on Wikipedia to see how it works
# this code was taken from rosettacode.org and would have been much more fun had I
# written it myself.
# In this script it is called by a function that discards the result if it's above
# a certain cutt off. It would speed things up if we could get this thing to
# stop if it becomes sure the result would be above the cuttoff
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

# Try to find a match for a progress marker based on description.
# If we can't find an exact match find the closest based on the Lavenshtein distance.
# Use a given outcome area and weighting to narrow down the search.
# If the closest distance is greater than the given cutoff return nil.
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

def set_level(progress_marker, geo_state, language, level)
  language_progress = LanguageProgress.find_or_create_by(progress_marker: progress_marker, language: language)
  if !language_progress.persisted?
    puts "Unable to find or create a language process object for #{progress_marker.name} : #{language.name}"
    if language_progress.errors.any?
      language_progress.errors.full_messages.each do |msg|
        puts msg
      end
    end
    raise "Unable to find or create a language process object for #{progress_marker.name} : #{language.name}"
  end
  existing_updates = ProgressUpdate.where(language_progress: language_progress,
    geo_state: geo_state,
    year: $baseline_year,
    month: $baseline_month)
  if existing_updates.empty? or existing_updates.max_by(&:created_at).progress != level
    progress_update = ProgressUpdate.create(
      user: $user,
      language_progress: language_progress,
      geo_state: geo_state,
      year: $baseline_year,
      month: $baseline_month,
      progress: level)
    return progress_update
  else
    return existing_updates.max_by(&:created_at)
  end
end

def parse_row(row, geo_states, languages, unmatched_progress_markers, pm_distance_cutoff)
  # the reason we grab the outcome area is because it is used, along with the weight
  # to narrow down the search for the right progress marker.
  outcome_area = Topic.find_by_name row[:outcome_area]
  if !outcome_area
    puts "could not find outcome area: #{row[:outcome_area]}"
    raise "could not find outcome area: #{row[:outcome_area]}"
  end
  progress_marker = match_progress_marker row[:progress_marker], outcome_area, row[:weight], unmatched_progress_markers, pm_distance_cutoff
  if !progress_marker
    return false
  end
  unmatched_progress_markers.delete progress_marker
  puts "PMs remaining: #{unmatched_progress_markers.count}"

  # now we've found the progress marker we can parse the rest of the row
  row.to_hash.slice!(:progress_marker, :outcome_area, :weight).each do |key, level|
    if level and level[/\d+/] # level contains digits
      update = set_level(progress_marker, geo_states[key], languages[key], level[/\d+/].to_i)
      if !update.persisted?
        puts "unable to save progress update"
        puts "#{progress_marker.name} : #{language.name}"
        update.errors.full_messages.each do |error_msg|
          puts error_msg
        end
      end
    end
  end
  return true
end

def import_from_file(filename)

  puts "importing data from #{filename}"
  file_data = CSV.table(filename, converters: :blank_to_nil)

  # the first row below the headers is the geo_states
  geo_state_data = file_data.delete(0).to_hash
  # the next is the language names
  language_data = file_data.delete(0).to_hash

  # collect together the languages and states for this dataset
  # the first 3 columns in each of these rows are not needed
  geo_states = Hash.new
  languages = Hash.new
  geo_state_data.slice!(:outcome_area, :weight, :progress_marker).each do |key, geo_state_name|
    if geo_state = GeoState.find_by_name(geo_state_name)
      geo_states[key] = geo_state
    else
      raise "Could not find State: #{geo_state_name}"
    end
    if language = Language.find_by_name(language_data[key])
      languages[key] = language
    else
      raise "Could not find language: #{language_data[key]}"
    end
    # check that the language is in the state
    if !languages[key].geo_states.include? geo_states[key]
      raise "#{language_data[key]} is not a member of #{geo_state_name}"
    end
  end

  # When parsing the rows of the spreadsheet, they each need to be
  # paired off with progress markers from the db
  unmatched_progress_markers = ProgressMarker.all.to_a
  unparsed_rows = Array.new
  file_data.each{ |row| unparsed_rows << row }
  # when trying to match PMs by description it's best to get the closest
  # matches out of the way first, so the cutoff for levenshtein distance
  # starts low and increases until all rows are dealt with
  cutoff = 0
  unable_to_parse = Array.new
  while unparsed_rows.any?
    unparsed_rows.each do |row|
      begin
        if parse_row(row, geo_states, languages, unmatched_progress_markers, cutoff)
          unparsed_rows.delete(row)
        end
      rescue
        # if we run out of PMs in a particular category to match against
        # this will happen
        puts $!.message
        unable_to_parse << unparsed_rows.delete(row)
      end
    end
    cutoff += 10
  end

  if unmatched_progress_markers.any?
    puts "there are #{unmatched_progress_markers.count} unused marker(s):"
    unmatched_progress_markers.each{ |pm| puts pm.description }
  end

  if unable_to_parse.any?
    puts "unable to parse #{unable_to_parse.count} row(s):"
    unable_to_parse.each{ |row| puts row[:progress_marker] }
  end

end

file_list.each do |file|
  import_from_file(file)
end
