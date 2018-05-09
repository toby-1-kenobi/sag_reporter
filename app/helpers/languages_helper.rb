module LanguagesHelper



  # get the string to link the map image for a language
  # return false if the image can't be found
  def get_map(language)
    # the file name is based on the language iso code
    if Rails.env.production? or Rails.env.development?
      # for production maps are stored in the cloud
      map_uri_base = "https://storage.googleapis.com/lci-language-maps/#{language.iso}"
      extensions = ['png', 'jpg']
      found_map_uri = false
      require 'open-uri'
      while !found_map_uri and extensions.any?
        begin
          found_map_uri = "#{map_uri_base}.#{extensions.shift}"
          open found_map_uri
        rescue => e
          found_map_uri = false
        end
      end
      found_map_uri
    else
      # for test and development maps are stored locally
      link_path = '/uploads/maps'
      storage_path = "public#{link_path}"
      if language.iso.present? and File.exists?("#{storage_path}/#{language.iso}.png")
        "#{link_path}/#{language.iso}.png"
      else
        false
      end
    end
  end

  def build_finish_line_table(languages, markers)
    check_list = markers.map{ |m| m.number }
    table = markers.map{ |marker| [marker, Hash.new(0)] }.to_h
    languages.each do |lang|
      lang_check_list = check_list.dup
      lang.finish_line_progresses.where(year: nil).each do |flp|
        marker = flp.finish_line_marker
        if table[marker]
          table[marker][flp.category] += 1
          lang_check_list.delete(marker.number)
        end
      end
      if lang_check_list.any?
        lang_check_list.each do |marker_number|
          marker = FinishLineMarker.find_by_number(marker_number)
          flp = lang.finish_line_progresses.find_or_create_by(finish_line_marker: marker)
          table[marker][flp.category] += 1
        end
      end
    end
    table
  end

  def colours_for_finish_line_data(data)
    colour_map = {nothing: 'grey', no_progress: 'blue', progress: 'orange', complete: 'green'}
    data.keys.map{ |status| colour_map[status] }
  end

  def colours_for_transformation_data(data)
    colour_map = {notseen: 'blue', emerging: 'gray', growingwell: 'orange', widespread: 'green'}
    data.keys.map{ |status| colour_map[status] }
  end

  def finish_line_progress_icon(category)
    case category
      when :no_progress
        '<i class="material-icons">star_border</i>'.html_safe
      when :progress
        '<i class="material-icons">star_half</i>'.html_safe
      when :complete
        '<i class="material-icons">star</i>'.html_safe
      else
        # show nothing for nothing
    end
  end

  # for the finish line transformation table
  # each language is categorized based on its transformation score
  # the value in the hash represents the max value for that bracket
  def transformation_brackets
    {
        notseen: 5,
        emerging: 50,
        growingwell: 70,
        widespread: 100
    }
  end

  def get_transformation(state_languages)
    # later we'll be putting progress updates into arrays by language progress so to save db hits
    # get them all now and pass them down in parameters
    all_updates = ProgressUpdate.joins(:language_progress).where(language_progresses: {state_language_id: state_languages}).to_a.group_by{ |pu| pu.language_progress_id }

    # for each project language get the aggregated data for both dates
    transformations = Hash.new
    # join progress updates to only include languages that have had baseline set.
    state_languages.joins(:progress_updates).includes(:language, {geo_state: :zone}, {:language_progresses =>[{:progress_marker => :topic}, :progress_updates]}).uniq.find_each do |state_language|
      transformations[state_language] = state_language.transformation_data(logged_in_user, true, all_updates)
    end
    transformations
  end

  def get_outcome_area()
    @outcome_area_colours = Hash.new
    Topic.find_each{ |oa| @outcome_area_colours[oa.name] = oa.colour }
    @outcome_area_colours['Overall'] = 'white'
    @outcome_area_colours
  end

  def scripture_engage_list
       se_list = ["New Testament", "Jesus Film", "Oral Bible Stories", "Gospel", "Old Testament"]
  end

  def getScriptureEngageCount(languages)
    count = 0
    languages.each do |lang|
      lang_count = 0
      lang.finish_line_progresses.each do |flp|
        marker = flp.finish_line_marker
        scripture_engage_list.each do |se|
          if marker.name == se and flp.category == :no_progress
            lang_count += 1
          end
        end
      end
      if lang_count == scripture_engage_list.length
        count += 1
      end
    end
    count
  end

  #for retrive engaged or translating language count of an organisation in a state
  def get_state_organisation_language_count(organisation, geo_state_id, type)
    count = 0
    display_text = ""
    case type
      when :engaged
        count = Language.joins([engaged_organisations: :engaged_languages], :state_languages).where(organisations: {id: organisation.id}, state_languages: {geo_state_id: geo_state_id}).uniq.length
      when :translation
        count = Language.joins([translating_organisations: :translating_languages] , :state_languages).where(organisations: {id: organisation.id}, state_languages: {geo_state_id: geo_state_id}).uniq.length

      else
        # show nothing for nothing
    end
    display_text = pluralize(count, 'language')
    display_text
  end

  #for retrive engaged or translating language count of an organisation in a zone
  def get_zone_organisation_language_count(organisation, zone_id, type)
    count = 0
    display_text = ""
    case type
      when :engaged
        count = Language.joins([engaged_organisations: :engaged_languages], [state_languages: :geo_state]).where(organisations: {id: organisation.id}, geo_states: {zone_id: zone_id}).uniq.length
      when :translation
        count = Language.joins([translating_organisations: :translating_languages], [state_languages: :geo_state]).where(organisations: {id: organisation.id}, geo_states: {zone_id: zone_id}).uniq.length
      else
        # show nothing for nothing
    end
    display_text = pluralize(count, 'language')
    display_text
  end

  #get currect year
  def get_current_year()
    current_year = Date.today.year
    if Date.today.month > 10 #year changed by october
      current_year += 1
    else
      current_year
    end
    current_year
  end

  def get_future_years(language)
    cur_year = get_current_year()
    future_years = []
    future_years.push(nil)
    years = FinishLineProgress.where(language: language).where.not(year: nil).where("year > #{cur_year}").distinct.pluck(:year)
    if is_user_have_future_plan()
      years.each do |year|
        future_years.push(year)
      end
    end
    future_years
  end

  def show_future_transformation(languages)
    future_data = {}
    max_year = 0
    future_trans =  []
    years = get_max_future_years()
    languages.each do |lang|
      years.each do |year|
        lang.finish_line_progresses.where(year: year).each do |flp|
          marker = flp.finish_line_marker.number
          future_trans[marker] ||= []
          future_trans[marker][year] ||= Hash.new(0)
          future_trans[marker][year][flp.category] += 1
          if max_year < year
            max_year = year
          end
        end
      end
    end
    future_data[:max_year] = max_year
    future_data[:future_trans] = future_trans
    future_data
  end

  def get_max_future_years()
    max_future_year = FinishLineProgress.where.not(year: nil).maximum(:year)
    max_future_years = []
    current_year = get_current_year()
    if(max_future_year != nil && current_year < max_future_year)
      current_year += 1
      (current_year..max_future_year).each do |year|
        max_future_years.push(year)
      end
    end
    max_future_years
  end

  def create_flp(language, flm, selected_year)
    #create new flp for future year if its not yet created
    # If selected year is current year will return current year values, nil represents current year
    max_year = nil
    finish_line_progress = Hash.new()
    if selected_year != nil
      max_year = FinishLineProgress.where(language: language, finish_line_marker: flm).where.not(year: nil).maximum(:year)

      if max_year.present?
        finish_line = FinishLineProgress.where(language: language, finish_line_marker: flm, year: max_year)
      else
        finish_line = FinishLineProgress.where(language: language, finish_line_marker: flm, year: nil)
      end

      #here it will create future year data with previous year status
      finish_line.each do |fl|
        finish_line_progress = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: flm, status: fl.status, year: selected_year)
      end
    else
      finish_line = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: flm, year: nil)
      finish_line_progress = finish_line
    end

    finish_line_progress
  end

  def get_cell_color(future_transformation, marker, language_amount, year, finish_line_data)
    no_progress = future_transformation[marker.number][year][:no_progress]
    progress = future_transformation[marker.number][year][:progress]
    completed = future_transformation[marker.number][year][:complete]
    current_year = get_current_year()

    progress_status = ""
    if no_progress == 0 && language_amount == (progress + completed)
      progress_status = "yellow"
    elsif ( no_progress == 0 && progress == 0 ) && (language_amount == completed )
      progress_status = "green"
    elsif finish_line_data[marker][:no_progress] <= future_transformation[marker.number][year][:no_progress] or
          finish_line_data[marker][:complete] > future_transformation[marker.number][year][:complete]
          progress_status = "red"
    end
    progress_status
  end

  def is_user_have_future_plan
    status = false
    if logged_in_user.admin == false &&
        logged_in_user.lci_board_member == false &&
        logged_in_user.lci_agency_leader == false

      status = true
    end
    status
  end

  def get_state_language_transformation(state_language)
    # later we'll be putting progress updates into arrays by language progress so to save db hits
    # get them all now and pass them down in parameters
    all_updates = ProgressUpdate.joins(:language_progress).where(language_progresses: {state_language_id: state_language.id}).to_a.group_by{ |pu| pu.language_progress_id }

    # for each project language get the aggregated data for both dates
    transformations = Hash.new
    # join progress updates to only include languages that have had baseline set.
    transformations = state_language.transformation_data(logged_in_user, true, all_updates)
    transformations
  end

  def get_future_transformation(state_languages, outcome_areas)
    current_year = get_current_year()
    future_years = []
    transformation = Hash.new()
    @future_transformation = Hash.new()

    outcome_areas.each do |outcome_area|
      transformation[outcome_area] ||= Hash.new()
    end

    forward_planning_targets = ForwardPlanningTarget.where(state_language: state_languages).where("year > ?", current_year)

    forward_planning_targets.order(:year).each do |fpt|

      transformation[fpt.topic.name][fpt.year] ||= Hash.new(0)
      value = fpt.targets

      all_brackets = transformation_brackets.keys
      # put this language in the first bracket
      language_bracket = all_brackets.shift
      # while its score is bigger than the bracket max value keep shifting it to the next bracket up.
      while value > transformation_brackets[language_bracket]
        language_bracket = all_brackets.shift
      end
      transformation[fpt.topic.name][fpt.year][language_bracket] += 1

      unless future_years.include?(fpt.year)
        future_years.push(fpt.year)
      end

    end
    @future_transformation[:future_years] = future_years
    @future_transformation[:transformation] = transformation
    @future_transformation
  end

end
