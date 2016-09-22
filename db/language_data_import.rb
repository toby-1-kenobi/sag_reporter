require 'csv'

data_file = Rails.root.join('db', 'language_data.csv')

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

errors = Hash.new

language_data = CSV.table(data_file, converters: :blank_to_nil)

p language_data.headers

state_names = GeoState.all.pluck(:name).to_a

def collect_states_from_location(lang, all_states, location_text)
  location_text_lc = location_text.downcase
  all_states.each do |state_name|
    if location_text_lc.include? state_name.downcase
      state = GeoState.find_by_name state_name
      if lang.geo_states.exclude? state
        lang.geo_states << state
      end
    end
  end
end

def addOrgs(lang, orgs_str, errors)
  lang.engaged_organisations.clear
  orgs_str.split(',').each do |org_str|
    org_str.strip!
    org = Organisation.find_by_name org_str
    org ||= Organisation.find_by_abbreviation org_str
    if org.nil?
      errors[lang.name] = Array.new if errors[lang.name].nil?
      errors[lang.name] << "couldn't find org: #{org_str}"
    else
      lang.engaged_organisations << org
    end
  end
end

def addTransOrgs(lang, orgs_str, errors)
  lang.translating_organisations.clear
  orgs_str.split('/').each do |org_str|
    org_str.strip!
    note = nil
    note_index = org_str.index /\(.*\)/
    if note_index
      note = org_str.slice!(note_index + 1..org_str.index(')') - 1).strip
      org_str.delete!('()').strip!
    end
    org = Organisation.find_by_name org_str
    org ||= Organisation.find_by_abbreviation org_str
    if org.nil?
      errors[lang.name] = Array.new if errors[lang.name].nil?
      errors[lang.name] << "couldn't find org: #{org_str}"
    else
      org_trans = OrganisationTranslation.new(language: lang, organisation: org, note: note)
      if (!org_trans.save)
        errors[lang.name] = Array.new if errors[lang.name].nil?
        errors[lang.name] << 'couldn\'t save organisation_translation'
        org_trans.errors.each_full{ |error| errors[lang.name] << error }
      end
    end
  end
end

def setTranslationStatus(lang, status, errors)
  case status.downcase
    when 'no need', 'no need in india'
      lang.translation_need = :no_need
      lang.translation_progress = :not_started
    when 'research need'
      lang.translation_need = :survey_required
      lang.translation_progress = :not_started
    when 'whole bible available', 'nt available'
      lang.translation_need = :need
      lang.translation_progress = :done
    when 'translation in progress'
      lang.translation_need = :need
      lang.translation_progress = :in_progress
    when 'limited need'
      lang.translation_need = :limited_need
      lang.translation_progress = :not_started
    when 'full tr need', 'translation planned 2016'
      lang.translation_need = :need
      lang.translation_progress = :not_started
    else
      errors[lang.name] = Array.new if errors[lang.name].nil?
      errors[lang.name] << "unknown translation status: #{status}"
  end
end

language_data.each do |row|
  lang = Language.find_or_initialize_by name: row[:language_name]
  if lang.new_record? and row[:state]
    state = GeoState.find_by_name(row[:state])
    if state
      lang.geo_states << state
    else
      errors[lang.name] = Array.new if errors[lang.name].nil?
      errors[lang.name] << "Can't find state #{row[:state]}"
    end
    if row[:location]
      collect_states_from_location(lang, state_names, row[:location])
    end
  end
  lang.iso ||= row[:iso]
  lang.family ||= LanguageFamily.find_or_create_by name: row[:lgfly]
  if row[:population]
    lang.population ||= row[:population].to_i
    if row[:pop_source]
      lang.pop_source ||= DataSource.find_or_create_by name: row[:pop_source]
    end
  end
  lang.location ||= row[:location]
  if row[:of_translations]
    lang.number_of_translations ||= row[:of_translations].to_i
  end
  if row[:cluster]
    lang.cluster ||= Cluster.find_or_create_by name: row[:cluster]
  end
  lang.info ||= row[:other_information]
  lang.translation_info ||= row[:decision_criteria]
  if row[:orgs_involved]
    addOrgs(lang, row[:orgs_involved], errors)
  end
  if row[:tr_org]
    addTransOrgs(lang, row[:tr_org], errors)
  end
  if row[:translation_statusneed]
    setTranslationStatus(lang, row[:translation_statusneed], errors)
  end
  if lang.save
    puts lang.name
  else
    errors[lang.name] = Array.new if errors[lang.name].nil?
    errors[lang.name] << 'could not save language'
  end
end

if errors.any?
  puts '*** Errors ***'
  errors.each do |lang, errors_array|
    errors_array.each { |error| puts "#{lang}: #{error}"}
  end
else
  puts 'no errors 🙂'
end
