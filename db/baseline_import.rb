require 'csv'

$baseline_year = 2016
$baseline_month = 12

# The data needs to be inserted under an existing user
# use the user called "Toby Anderson" and if he doesn't exist take the first admin user
$user = User.find_by_name 'Toby Anderson'
if !$user
  admin_role = Role.find_by_name 'admin'
  $user = User.where(role: admin_role).take
end

$pm_cache = Hash.new

# count the updates we actually make
$update_count = 0

file_list = Dir[Rails.root.join('db', 'baseline_data', $baseline_year.to_s, '**', '*.csv')]

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end


def set_level(progress_marker, geo_state, language, level)
  state_language = StateLanguage.includes(:language).find_by(geo_state: geo_state, language: language)
  if !state_language
    raise "Could not find state language for #{geo_state.name} - #{language.name}."
  end

  # it should be a project state-language so make sure it is
  unless state_language.project
    state_language.project = true
    state_language.save
  end

  language_progress = LanguageProgress.find_or_create_by(progress_marker: progress_marker, state_language: state_language)
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
    if progress_update
      puts "#{state_language.language_name}: progress level set to #{level}"
      $update_count += 1
    else
      puts "#{state_language.language_name}: unable to set progress level!"
    end
    return progress_update
  else
    pm = existing_updates.max_by(&:created_at)
    puts "#{state_language.language_name}: skipping - progress level was already set at #{pm.progress} (baseline file has #{level})"
    return pm
  end
end

def parse_row(row, geo_states, languages)
  # get the progress marker
  $pm_cache[row[:pm_number]] ||= ProgressMarker.find_by_number!(row[:pm_number])
  progress_marker = $pm_cache[row[:pm_number]]

  # now we've found the progress marker we can parse the rest of the row
  row.to_hash.slice!(:pm_number).each do |key, level|
    if level and level[/\d+/] # level contains digits
      update = set_level(progress_marker, geo_states[key], languages[key], level[/\d+/].to_i)
      if !update.persisted?
        puts 'unable to save progress update'
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
  # the first column in each of these rows is not needed
  geo_states = Hash.new
  languages = Hash.new
  geo_state_data.slice!(:pm_number).each do |key, geo_state_name|
    if geo_state_name.present? or language_data[key].present?
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
  end

  unparsed_rows = Array.new
  file_data.each{ |row| unparsed_rows << row }
  unable_to_parse = Array.new
  while unparsed_rows.any?
    unparsed_rows.each do |row|
      # begin
        if parse_row(row, geo_states, languages)
          unparsed_rows.delete(row)
        end
      # rescue
      #   unparsed_rows.delete(row)
      #   unable_to_parse << "#{row[:pm_number]}: #{$!.message}"
      # end
    end
  end

  if unable_to_parse.any?
    puts "unable to parse #{unable_to_parse.count} row(s):"
    unable_to_parse.each{ |row| puts row }
  end

end

file_list.each do |file|
  import_from_file(file)
end

puts "Total number of updates: #{$update_count}"

# Now for all deprecated progress markers we need to set the update to 0
# in the same month we are putting the baseline data into.
# This will allow us to maintain a historical record of progress updates
# in deprecated markers, but prevent the score from these polluting the scores
# for the new set of markers

LanguageProgress.joins(:progress_marker).where('progress_markers.status' => 1).each do |lp|
  geo_state = lp.state_language.geo_state
  lp.progress_updates.create(
      user: $user,
      geo_state: geo_state,
      year: $baseline_year,
      month: $baseline_month,
      progress: 0)
end
