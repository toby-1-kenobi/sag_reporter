# merge two languages
# expect the row id of each language as command line arguments
# the second id will refer to the language that's being kept

def convert_reports(from_lang, to_lang)
  from_lang.reports.each do |report|
    to_lang.reports << report unless to_lang.reports.include? report
  end
  from_lang.reports.clear
end

def convert_speakers(from_lang, to_lang)
  from_lang.user_speakers.each do |user|
    to_lang.user_speakers << user unless to_lang.user_speakers.include? user
  end
  from_lang.user_speakers.clear
end

def convert_language_names(from_lang, to_lang)
  # first remove names already in the "to" language
  from_lang.language_names.where(name: to_lang.language_names.pluck(:name)).destroy_all
  # then shift the others across
  from_lang.language_names.update_all(language_id: to_lang.id)
end

def convert_states(from_lang, to_lang)
  from_lang.state_languages.each do |from_sl|
    if to_sl = to_lang.state_languages.where(geo_state: from_sl.geo_state).first
      merge_state_languages(from_sl, to_sl)
    else
      from_sl.update_attribute(:language_id, to_lang.id)
    end
  end
end

def merge_state_languages(from_sl, to_sl)
  if from_sl.project?
    to_sl.update_attribute(:project, true)
  end
  from_sl.language_progresses.find_each do |lp|
    new_lp = LanguageProgress.find_or_create_by(state_language: to_sl, progress_marker: lp.progress_marker)
    lp.progress_updates.update_all(language_progress_id: new_lp.id)
    lp.destroy
  end
  from_sl.destroy
end

def convert_translating_organisations(from_lang, to_lang)
  from_lang.translating_organisations.each do |org|
    OrganisationTranslation.find_or_create_by(language: to_lang, organisation: org)
    from_lang.translating_organisations.delete org
  end
end

def convert_engaged_organisations(from_lang, to_lang)
  from_lang.engaged_organisations.each do |org|
    OrganisationEngagement.find_or_create_by(language: to_lang, organisation: org)
    from_lang.engaged_organisations.delete org
  end
end

from_lang = Language.find ARGV[0]
to_lang = Language.find ARGV[1]

puts "merging #{from_lang} into #{to_lang}"
puts 'continue?'
response = STDIN.gets.chomp

if response.start_with?('y')

  names = from_lang.language_names.count
  if names > 0
    puts "converting #{names} language names"
    convert_language_names(from_lang, to_lang)
  else
    puts 'no language names'
  end

  dialects = from_lang.dialects.count
  if dialects > 0
    puts "converting #{dialects} dialects"
    convert_dialects(from_lang, to_lang)
  else
    puts 'no dialects'
  end

  mt_speakers_count = from_lang.user_mt_speakers.count
  if mt_speakers_count > 0
    puts "converting #{mt_speakers_count} mother tongue speakers"
    from_lang.user_mt_speakers.update_all(mother_tongue_id: to_lang.id)
  else
    puts 'no mother tongue speakers'
  end

  speakers_count = from_lang.user_speakers.count
  if speakers_count > 0
    puts "converting #{speakers_count} L2 speakers"
    convert_speakers(from_lang, to_lang)
  else
    puts 'no L2 speakers'
  end

  mt_resources_count = from_lang.mt_resources.count
  if mt_resources_count > 0
    puts "converting #{mt_resources_count} mother tongue resources"
    from_lang.mt_resources.update_all(language_id: to_lang.id)
  else
    puts 'no mother tongue resources'
  end

  report_count = from_lang.reports.count
  if report_count > 0
    puts "converting #{report_count} reports"
    convert_reports(from_lang, to_lang)
  else
    puts 'no reports'
  end

  event_count = from_lang.events.count
  if event_count > 0
    puts "converting #{event_count} events"
    convert_events(from_lang, to_lang)
  else
    puts 'no events'
  end

  state_count = from_lang.geo_states.count
  if state_count > 0
    puts "converting #{state_count} states"
    convert_states(from_lang, to_lang)
  else
    puts 'no states'
  end

  engaged_organisation_count = from_lang.engaged_organisations.count
  if engaged_organisation_count > 0
    puts "converting #{engaged_organisation_count} engaged_organisations"
    convert_engaged_organisations(from_lang, to_lang)
  else
    puts 'no engaged_organisations'
  end

  translating_organisation_count = from_lang.translating_organisations.count
  if translating_organisation_count > 0
    puts "converting #{translating_organisation_count} translating_organisations"
    convert_translating_organisations(from_lang, to_lang)
  else
    puts 'no translating_organisations'
  end

  puts 'converting pending edits'
  Edit.where(model_klass_name: 'Language', record_id: from_lang.id).update_all(record_id: to_lang.id)

  puts "Ready to delete #{from_lang.name}"
  puts 'continue?'
  response = STDIN.gets.chomp

  if response.start_with?('y')
    from_lang.reload
    puts "deleting #{from_lang.name}"
    from_lang.destroy
  end

end
