data_file = Rails.root.join('db', 'losa_data.txt')
puts data_file

def parse_line(line)
  parsed_line = {}
  if line.start_with? "\\"
    space_index = line.index(' ')
    if space_index
      parsed_line[:marker] = line[1..space_index - 1]
      parsed_line[:value] = line[space_index..-1].strip
    else
      parsed_line[:marker] = line[1..-1]
      parsed_line[:value] = ''
    end
  else
    parsed_line[:value] = line.strip
  end
  parsed_line
end

def attribute(marker)
  case marker
    when 'XXX'
      :iso
    when 'NAM'
      :name
    when 'NAL'
      :language_names
    when 'NPE'
      :name_speakers_use
    when 'NPO'
      :name_others_use
    when 'PTO'
      :population_all_countries
    when 'POP'
      :population
    when 'R'
      :info
    when 'VLF'
      :village_size
    when 'MXM'
      :mixed_marriages
    when 'PCL'
      :clans
    when 'NCA'
      :castes
    when 'REG'
      :location
    when 'ACC'
      :location_access
    when 'SI'
      :location_access_2
    when 'TRV'
      :travel
    when 'ETH'
      :ethnic_groups_in_area
    when 'REL'
      :religion
    when 'BLV'
      :believers
    when 'LOF'
      :local_fellowship
    when 'PBL'
      :literate_believers
    when 'G'
      :genetic_classification
    when 'INR'
      :related_languages
    when 'D'
      :dialects
    when 'NCA'
      :subgroups
    when 'LXS'
      :lexical_similarity
    when 'ATT'
      :attitude
    when 'BB'
      :bible_first_published
    when 'NT'
      :nt_first_published
    when 'PR'
      :portions_first_published
    when 'SEL'
      :selections_published
    when 'NX'
      :nt_out_of_print
    when 'IEE'
      :translation_info
    when 'BT'
      :translation_consultants
    when 'TIN'
      :translation_interest
    when 'BKT'
      :translator_background
    when 'CMT'
      :tr_committee_established
    when 'LSP'
      :translation_local_support
    when 'LIV'
      :mt_literacy
    when 'LIR'
      :l2_literacy
    when 'WR'
      :script
    when 'ALD'
      :attitude_to_lang_dev
    when 'LSU'
      :mt_literacy_programs
    when 'LY'
      :poetry_print
    when 'LK'
      :oral_traditions_print
    else
      false
  end
end

class String
  def from_sentence(words_connector: ',', two_words_connector: ' and ', last_word_connector: ', and ')
    self.gsub(/#{last_word_connector}/,"#{words_connector}").gsub(/#{two_words_connector}/,"#{words_connector}").split("#{words_connector}").map(&:strip)
  end
end

def process_language_names(lang, record)
  names = record.delete(:language_names).from_sentence.map{ |n| n.humanize }
  existing_names = lang.language_names.pluck :name
  names.each do |name|
    lang.language_names.create(name: name) unless existing_names.include? name
  end
end

def process_insider_names(lang, record)
  names = record.delete(:name_speakers_use).from_sentence.map{ |n| n.humanize }
  names.each do |name|
    name_obj = lang.language_names.find_or_initialize_by(name: name)
    name_obj.used_by_speakers = true
    name_obj.save!
  end
end

def process_outsider_names(lang, record)
  names = record.delete(:name_others_use).from_sentence.map{ |n| n.humanize }
  names.each do |name|
    name_obj = lang.language_names.find_or_initialize_by(name: name)
    name_obj.used_by_outsiders = true
    name_obj.save!
  end
end

def process_preferred_name(lang, name)
  name_obj = lang.language_names.find_or_initialize_by(name: name.humanize)
  name_obj.preferred = true
  name_obj.save!
end

def process_dialects(lang, record)
  dialects = record.delete(:dialects).from_sentence.map{ |n| n.humanize }
  existing_dialects = lang.dialects.pluck :name
  dialects.each do |dialect|
    lang.dialects.create(name: dialect) unless existing_dialects.include? dialect
  end
end

def fix_population(lang, record)
  # don't overwrite population that's already in the database.
  record.delete(:population) if lang.population
  
  if record[:population].present?
    # remove commas
    record[:population] = record[:population].tr(',', '')
    if record[:population].match /(\d\d*) ?- ?(\d\d*)/
      # average of range
      record[:population] = ($1.to_i + $2.to_i) / 2
    else
      record[:population] = record[:population].to_i
    end
  end

  if record[:population_all_countries].present?
    record[:population_all_countries] = record[:population_all_countries].tr(',', '')
    if record[:population_all_countries].match /(\d\d*) ?- ?(\d\d*)/
      record[:population_all_countries] = ($1.to_i + $2.to_i) / 2
    else
      record[:population_all_countries] = record[:population_all_countries].to_i
    end
  end


  if record[:believers].present?
    # make sure the entry starts with a digit others we'll get 0 on to_i
    if record[:believers].match /^\d/
      record[:believers] = record[:believers].tr(',', '')
      if record[:believers].match /(\d\d*) ?- ?(\d\d*)/
        record[:believers] = ($1.to_i + $2.to_i) / 2
      else
        record[:believers] = record[:believers].to_i
      end
    else
      # if it doesn't skip it.
      record.delete(:believers)
    end
  end
end

def fix_location_access(record)
  if record[:location_access_2] == 'Y'
    record.delete(:location_access_2)
  elsif record[:location_access].present?
    record[:location_access] += " Also, #{record.delete(:location_access_2)}"
  else
    record[:location_access] = record.delete(:location_access_2)
  end
end

def process_pre_existing_fields(lang, record)
  if lang.info.present? and record[:info].present?
    lang.info = lang.info.gsub(" Also, #{record[:info]}", '')
    if lang.info.include? record[:info]
      record.delete(:info)
    else
      lang.info += " Also, #{record.delete(:info)}" if lang.info.present?
    end
  end
  if lang.location.present? and record[:location].present?
    lang.location = lang.location.gsub(" Also, #{record[:location]}", '')
    if lang.location.include? record[:location]
      record.delete(:location)
    else
      lang.location += " Also, #{record.delete(:location)}" if lang.location.present?
    end
  end
  if lang.translation_info.present? and record[:translation_info].present?
    lang.translation_info = lang.translation_info.gsub(" Also, #{record[:translation_info]}", '')
    if lang.translation_info.include? record[:translation_info]
      record.delete(:translation_info)
    else
      lang.translation_info += " Also, #{record.delete(:translation_info)}" if lang.translation_info.present?
    end
  end
end

def process_pub_dates(record)
  if record[:bible_first_published].present?
    if record[:bible_first_published].match(/(\d{4}).*(\d{4})/)
      record[:bible_first_published] = $1.to_i
      record[:bible_last_published] = $2.to_i
    else
      record[:bible_first_published] = record[:bible_first_published].to_i
    end
  end
  if record[:nt_first_published].present?
    if record[:nt_first_published].match(/(\d{4}).*(\d{4})/)
      record[:nt_first_published] = $1.to_i
      record[:nt_last_published] = $2.to_i
    else
      record[:nt_first_published] = record[:nt_first_published].to_i
    end
  end
  if record[:portions_first_published].present?
    if record[:portions_first_published].match(/(\d{4}).*(\d{4})/)
      record[:portions_first_published] = $1.to_i
      record[:portions_last_published] = $2.to_i
    else
      record[:portions_first_published] = record[:portions_first_published].to_i
    end
  end
end

def fix_bools(record)
  record[:local_fellowship] = record[:local_fellowship] == 'Y' if record[:local_fellowship].present?
  record[:nt_out_of_print] = record[:nt_out_of_print] == 'Y' if record[:nt_out_of_print].present?
  record[:tr_committee_established] = record[:tr_committee_established] == 'Y' if record[:tr_committee_established].present?
  record[:poetry_print] = record[:poetry_print] == 'Y' if record[:poetry_print].present?
  record[:oral_traditions_print] = record[:oral_traditions_print] == 'Y' if record[:oral_traditions_print].present?
end

def process_record(record)
  lang = Language.find_by_iso(record[:iso].downcase) if record[:iso]
  if lang
    puts "processing #{lang.name} [#{lang.iso}]"
    process_language_names(lang, record) if record[:language_names].present?
    process_insider_names(lang, record) if record[:name_speakers_use].present?
    process_outsider_names(lang, record) if record[:name_others_use].present?
    process_preferred_name(lang, record.delete(:name)) if record[:name].present?
    process_dialects(lang, record) if record[:dialects].present?
    fix_population(lang, record)
    fix_location_access(record) if record[:location_access_2].present?
    process_pre_existing_fields(lang, record)
    process_pub_dates(record)
    fix_bools(record)
    lang.update_attributes(record)
    if lang.save
      lang
    else
      false
    end
  else
    false
  end
end

relevant_record = false
current_record = {}
current_key = nil
unprocessed_records = []
successful = []
failed = {}
File.foreach(data_file) do |line|
  parsed_line = parse_line(line)
  if parsed_line[:marker].present? and parsed_line[:marker] == 'Key'
    # new record so process the current one
    if current_record.any?
      begin
        result = process_record(current_record)
        if result
          successful << result
        else
          unprocessed_records << current_record
        end
      rescue => e
        failed["#{current_record[:name]} [#{current_record[:iso]}]"] = e.message
      end
    end
    # skip over it if it's outside India
    relevant_record = parsed_line[:value].include? 'India'
    # reset the current record
    current_record = {}
  end

  if relevant_record
    if parsed_line[:marker].present?
      attribute_name = attribute(parsed_line[:marker])
      if attribute_name
        current_key = attribute_name
        current_record[attribute_name] = parsed_line[:value]
      else
        current_key = false
      end
    else
      # continuation of the previous line
      current_record[current_key] += " #{parsed_line[:value]}" if current_key
    end
  end
end

if unprocessed_records.any?
  puts "couldn't process #{unprocessed_records.count} records."
end

if failed.any?
  puts "failed when processing #{failed.count} languages."
  failed.each do |record_id, failure|
    puts "    #{record_id}: #{failure}"
  end
end

if successful.any?
  puts "successfully processed #{successful.count} languages."
end
