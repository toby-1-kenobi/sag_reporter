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
    # year ticks over on October 1st
    year_cutoff_month = 10
    year_cutoff_day = 1
    current_year = Date.today.year
    cutoff_date = Date.new(current_year, year_cutoff_month, year_cutoff_day)
    if Date.today >= cutoff_date
      return current_year + 1
    else
      return current_year
    end
  end

  def get_future_years(language)
    cur_year = get_current_year()
    future_years = []
    future_years.push(nil)
    years = FinishLineProgress.where(language: language).where.not(year: nil).where("year > #{cur_year}").distinct.pluck(:year)
    if logged_in_user.can_future_plan?
      years.each do |year|
        future_years.push(year)
      end
    end
    future_years
  end

  def forward_planning_finish_line_data(languages, markers)
    max_year = FinishLineProgress.languages(languages).where.not(year: nil).maximum(:year)
    return {} unless max_year
    min_year = FinishLineProgress.languages(languages).where.not(year: nil).minimum(:year)
    planning_data = {} # for the aggregate

    # first collect all the required finish line statuses
    languages.each do |lang|
      language_data = {} # for this language
      (min_year .. max_year).each do |year|
        language_data[year] = {}
        planning_data[year] ||= {}
        markers.each do |marker|
          planning_data[year][marker.number] ||= Hash.new(0)
          flp = lang.finish_line_progresses.find_by(year: year, finish_line_marker: marker)
          if flp
            # if we have the finish line progress for this language, year and marker
            # then record its status
            language_data[year][marker] = flp.status
          elsif language_data[year - 1]
            # otherwise if we found one for the year before use that for the status
            language_data[year][marker] = language_data[year - 1][marker]
          else
            # otherwise use the one for current year (if necessary creating it with default status)
            flp = FinishLineProgress.find_or_create_by(language: lang, year: nil, finish_line_marker: marker)
            language_data[year][marker] = flp.status
          end
          # aggregate as we go
          status = language_data[year][marker]
          planning_data[year][marker.number][FinishLineProgress.category(status)] += 1
        end
      end
    end
    Rails.logger.debug(planning_data)
    return planning_data
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
    if selected_year != nil
      max_year = FinishLineProgress.where(language: language, finish_line_marker: flm).where.not(year: nil).maximum(:year)
    end

    if max_year.present?
      finish_line = FinishLineProgress.where(language: language, finish_line_marker: flm, year: max_year)
    else
      finish_line = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: flm, year: nil)
    end
    finish_line_progress = Hash.new()

    if selected_year != nil
      #here it will create future year data with previous year status
      finish_line.each do |fl|
        finish_line_progress = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: flm, status: fl.status, year: selected_year)
      end
    else
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

end
