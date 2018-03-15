# populate the database with random progress updates for a given month

# dont run this in production
if Rails.env.production?
  puts 'not to be run in production, exiting'
  exit(false)
end

puts "year? "
year = gets.chomp.to_i
puts "month? (number) "
month = gets.chomp.to_i

# first user in db will be the one to have set these
user = User.take

lps = []

# ensure language progresses for each active pm in each project language
StateLanguage.in_project.each do |state_lang|
  ProgressMarker.active.each do |pm|
    lps << LanguageProgress.find_or_create_by(state_language: state_lang, progress_marker: pm)
  end
end

# progress values from which to select
progress_options = ProgressMarker.spread_text.keys

# add a progress update to each language progress with the given month and random value
lps.each do |lp|
  lp.progress_updates.create(year: year, month: month, user: user, progress: progress_options.sample)
end