require 'csv'

data_file = Rails.root.join('db', 'primary_states.csv')

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

data = CSV.table(data_file, converters: :blank_to_nil, headers: false)

states = {}
errors = []
processing_states = true

data.each do |row|
  if row[0] == '***'
    processing_states = false
  else
    if processing_states
      state = GeoState.find_by_name row[1]
      if state
        states[row[0]] = state
        puts "#{row[0]}: #{state.name} (#{state.id})"
      else
        errors << "couldn't find state: #{row[1]}"
      end
    else
      lang = Language.find_by_iso row[1]
      lang ||= Language.find_by_name row[0]
      state = states[row[2]]
      if state
        if lang
          state_language = StateLanguage.find_or_create_by(language: lang, geo_state: state)
          state_language.primary = true
          state_language.save
        else
          errors << "could not find language: #{row[0]} (#{row[1]})"
        end
      else
        errors << "bad state code: #{row[2]}"
      end
    end
  end
end

if errors.any?
  puts "#{errors.count} errors:"
  errors.each{ |e| puts e}
end