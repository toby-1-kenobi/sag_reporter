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
    table[:vision] = Hash.new(0)
    languages.each do |lang|
      lang_check_list = check_list.dup
      fl_status_data = {}
      flp_array = lang.finish_line_progresses.to_a
      flp_array.select{ |flp| flp.year == nil }.each do |flp|
        marker = flp.finish_line_marker
        fl_status_data[marker.number] = flp.status
        if table[marker]
          table[marker][flp.category] += 1
          lang_check_list.delete(marker.number)
        end
      end
      if lang_check_list.any?
        lang_check_list.each do |marker_number|
          marker = FinishLineMarker.find_by_number(marker_number)
          flp = lang.finish_line_progresses.find_or_create_by(finish_line_marker: marker)
          fl_status_data[marker.number] = flp.status
          table[marker][flp.category] += 1
        end
      end
      table[:vision][vision_hit(fl_status_data)] += 1
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

  #for retrieve engaged or translating language count of an organisation in a state
  def get_state_organisation_language_count(organisation, geo_state_id, type)
    case type
      when :engaged
        count = Language.joins([engaged_organisations: :engaged_languages], :state_languages).where(organisations: {id: organisation.id}, state_languages: {geo_state_id: geo_state_id}).uniq.length
      when :translation
        count = Language.joins([translating_organisations: :translating_languages] , :state_languages).where(organisations: {id: organisation.id}, state_languages: {geo_state_id: geo_state_id}).uniq.length
      else
        count = 0
    end
    pluralize(count, 'language')
  end

  #for retrieve engaged or translating language count of an organisation in a zone
  def get_zone_organisation_language_count(organisation, zone_id, type)
    case type
      when :engaged
        count = Language.joins([engaged_organisations: :engaged_languages], [state_languages: :geo_state]).where(organisations: {id: organisation.id}, geo_states: {zone_id: zone_id}).uniq.length
      when :translation
        count = Language.joins([translating_organisations: :translating_languages], [state_languages: :geo_state]).where(organisations: {id: organisation.id}, geo_states: {zone_id: zone_id}).uniq.length
      else
        count = 0
    end
    pluralize(count, 'language')
  end

  def get_future_years(language)
    cur_year = FinishLineProgress.get_current_year
    future_years = []
    future_years.push(nil)
    if logged_in_user.can_future_plan? or logged_in_user?(language.champion)
      years = FinishLineProgress.where(language: language).where.not(year: nil).where("year > #{cur_year}").distinct.pluck(:year)
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
      language_data = {} # fresh hash for this language
      # finish line progresses should already be fetched from the db
      # put them in array here
      flp_array = lang.finish_line_progresses.to_a
      (min_year .. max_year).each do |year|
        language_data[year] = {}
        planning_data[year] ||= {}
        planning_data[year][:vision] ||= Hash.new(0)
        markers.each do |marker|
          planning_data[year][marker.number] ||= Hash.new(0)
          flp = flp_array.select{ |flp| flp.year == year and flp.finish_line_marker_id == marker.id }.first
          if flp
            # if we have the finish line progress for this language, year and marker
            # then record its status
            language_data[year][marker.number] = flp.status
          elsif language_data[year - 1]
            # otherwise if we found one for the year before use that for the status
            language_data[year][marker.number] = language_data[year - 1][marker.number]
          else
            # otherwise use the one for current year (if necessary creating it with default status)
            flp = flp_array.select{ |flp| flp.year == nil and flp.finish_line_marker_id == marker.id }.first
            flp ||= FinishLineProgress.find_or_create_by(language: lang, year: nil, finish_line_marker: marker)
            language_data[year][marker.number] = flp.status
          end
          # aggregate as we go
          status = language_data[year][marker.number]
          planning_data[year][marker.number][FinishLineProgress.category(status)] += 1
        end
        # also calculate a row in the table for vision 2025 and vision 2033
        planning_data[year][:vision][vision_hit(language_data[year])] += 1
      end
    end
    planning_data
  end

  # for a language that hasn't reached Vision 2025 goals returns :no_progress
  # for a language that has reached V2025 but not V2033 returns :progress
  # for a language that has reached Vision 2033 goals returns :complete
  def vision_hit(finish_line_data)
    # These "constants" pulled from database id of records
    # and from enums in FinishLineMarker model
    # if any of them changes this breaks
    # TODO: make this less brittle
    nt_marker_id = 6
    ot_marker_id = 7
    story_marker_id = 2
    possible_need_status_index = 1
    confirmed_need_status_index = 2
    in_progress_status_index = 3
    further_need_status_index = 5
    inaccessible_status_index = 7
    in_progress_level = 3

    # check if language not accessible. Check only against NT marker.
    if finish_line_data[nt_marker_id] == FinishLineProgress.statuses.key(inaccessible_status_index) or
        finish_line_data[story_marker_id] == FinishLineProgress.statuses.key(inaccessible_status_index)
      return :not_accessible
    end

    ot_status = finish_line_data[ot_marker_id]
    ot_no_need = ot_status != FinishLineProgress.statuses.key(in_progress_status_index) and
        ot_status != FinishLineProgress.statuses.key(further_need_status_index) and
        ot_status != FinishLineProgress.statuses.key(confirmed_need_status_index)
    storying_status = finish_line_data[story_marker_id]
    storying_no_need = storying_status != FinishLineProgress.statuses.key(possible_need_status_index) and
        storying_status != FinishLineProgress.statuses.key(confirmed_need_status_index) and
        storying_status != FinishLineProgress.statuses.key(in_progress_status_index)
    nt_category = FinishLineProgress.category(finish_line_data[nt_marker_id])

    if nt_category == :complete and ot_no_need
      :complete
    elsif nt_category == :nothing and storying_no_need
      :complete
    elsif nt_category == :progress or nt_category == :complete
      :progress
    else
      storying_level = FinishLineProgress.progress_level(finish_line_data[story_marker_id])
      if storying_level >= in_progress_level
        :progress
      else
        :no_progress
      end
    end
  end

  # find a finish line progress from a set for a given language marker and year
  # if that doesn't exist find the one that matches language and marker
  # with maximum year less than the given year
  # when no markers of any year match find the one for current year (year == nil)
  def flp_closest_to(flm_id, year, progresses)
    flp = progresses.
        select{ |prog| prog.finish_line_marker_id == flm_id and prog.year != nil and prog.year <= year.to_i }.
        max_by{ |prog| prog.year }
    flp ||= progresses.select{ |prog| prog.finish_line_marker_id == flm_id and prog.year == nil }.last
    flp
  end

  def get_max_future_years()
    max_future_year = FinishLineProgress.where.not(year: nil).maximum(:year)
    max_future_years = []
    current_year = FinishLineProgress.get_current_year
    if(max_future_year != nil && current_year < max_future_year)
      current_year += 1
      (current_year..max_future_year).each do |year|
        max_future_years.push(year)
      end
    end
    max_future_years
  end

  def target_met?(current_data, target_data)
    if current_data[:complete] < target_data[:complete]
      false
    elsif current_data[:progress] < target_data[:progress] and current_data[:no_progress] > target_data[:no_progress]
      false
    else
      true
    end
  end

  def planning_cell_status(cell_data)
    if cell_data[:no_progress] > 0
      'data-not-all-started'
    elsif cell_data[:progress] > 0
      'data-all-started'
    else
      'data-all-complete'
    end
  end

end
