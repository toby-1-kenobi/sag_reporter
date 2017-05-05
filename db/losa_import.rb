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
    when 'SI'
      :location_access_1
    when 'ACC'
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
      :translation_progress
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

def process_record(record)
  lang = Language.find_by_iso(record[:iso].downcase) if record[:iso]
  if lang
    puts "found language #{lang.name} [#{lang.iso}]"
  else
    puts "couldn't find language #{record[:name]} [#{record[:iso]}]"
  end
end

relevant_record = false
current_record = {}
current_key = nil
File.foreach(data_file) do |line|
  parsed_line = parse_line(line)
  if parsed_line[:marker].present? and parsed_line[:marker] == 'Key'
    # new record
    process_record(current_record) unless current_record.empty?
    # skip over it if it's outside India
    relevant_record = parsed_line[:value].include? 'India'
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