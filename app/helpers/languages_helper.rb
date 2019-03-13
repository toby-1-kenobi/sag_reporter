require 'securerandom'
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
      years.sort.each do |year|
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
    survey_needed_status_index = 1
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
    storying_no_need = storying_status != FinishLineProgress.statuses.key(survey_needed_status_index) and
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

  def board_report_figures(language_data)
    data = {}

    #TODO: don't use finish line marker names directly here - it's too brittle
    nt_complete, rest = language_data.partition do |l|
      l['New Testament'] == 'completed' or
          l['New Testament'] == 'further_needs_expressed' or
          l['New Testament'] == 'further_work_in_progress'
    end

    bible_available, nt_available = nt_complete.partition do |l|
      l['Old Testament'] == 'completed' or
          l['Old Testament'] == 'further_needs_expressed' or
          l['Old Testament'] == 'further_work_in_progress'
    end
    data[:nt_available] = [nt_available.count, nt_available.sum{ |l| l[:pop] }]
    data[:bible_available] = [bible_available.count, bible_available.sum{ |l| l[:pop] }]

    inaccessible, rest = rest.partition do |l|
      l['New Testament'] == 'not_accessible' or
          l['Gospel'] == 'not_accessible' or
          l['Oral Bible Stories'] == 'not_accessible'
    end
    data[:inaccessible] = [inaccessible.count, inaccessible.sum{ |l| l[:pop] }]

    outside_india, rest = rest.partition do |l|
      l['New Testament'] == 'outside_india_in_progress' or
          l['Gospel'] == 'outside_india_in_progress' or
          l['Oral Bible Stories'] == 'outside_india_in_progress'
    end
    data[:outside_india] = [outside_india.count, outside_india.sum{ |l| l[:pop] }]

    nt_progress, rest = rest.partition do |l|
      l['New Testament'] == 'in_progress' or
          l['Gospel'] == 'in_progress'
    end
    data[:nt_progress] = [nt_progress.count, nt_progress.sum{ |l| l[:pop] }]

    no_need, rest = rest.partition do |l|
      l['New Testament'] == 'no_need' and
          l['Gospel'] == 'no_need' and
          l['Oral Bible Stories'] == 'no_need'
    end
    data[:no_need] = [no_need.count, no_need.sum{ |l| l[:pop] }]

    survey_needed, rest = rest.partition do |l|
      l['Oral Bible Stories'] == 'survey_needed' or
          l['Oral Bible Stories'] == 'confirmed_need'
    end
    data[:survey_needed] = [survey_needed.count, survey_needed.sum{ |l| l[:pop] }]

    storying_in_progress, rest = rest.partition do |l|
      l['Oral Bible Stories'] == 'in_progress'
    end
    data[:obs_progress] = [storying_in_progress.count, storying_in_progress.sum{ |l| l[:pop] }]

    data[:storying_complete] = [rest.count, rest.sum{ |l| l[:pop] }]

    ot_planned = language_data.select do |l|
      l['Old Testament'] == 'confirmed_need'
    end
    data[:ot_planned] = [ot_planned.count, ot_planned.sum{ |l| l[:pop] }]

    ot_progress = language_data.select do |l|
      l['Old Testament'] == 'in_progress'
    end
    data[:ot_progress] = [ot_progress.count, ot_progress.sum{ |l| l[:pop] }]

    jesus_film = language_data.select{ |l| l['Jesus Film'] == 'confirmed_need' or l['Jesus Film'] == 'in_progress' }
    data[:jesus_film] = [jesus_film.count, jesus_film.sum{ |l| l[:pop] }]

    songs = language_data.select{ |l| l['Songs Set'] == 'confirmed_need' or l['Songs Set'] == 'in_progress' }
    data[:songs] = [songs.count, songs.sum{ |l| l[:pop] }]

    literacy = language_data.select{ |l| l['LCI Literacy Classes'] == 'confirmed_need' or l['LCI Literacy Classes'] == 'in_progress' }
    data[:literacy] = [literacy.count, literacy.sum{ |l| l[:pop] }]

    parivartan = language_data.select{ |l| l['LCI Parivartan Groups'] == 'confirmed_need' or l['LCI Parivartan Groups'] == 'in_progress' }
    data[:parivartan] = [parivartan.count, parivartan.sum{ |l| l[:pop] }]

    dictionary = language_data.select{ |l| l['Dictionary'] == 'confirmed_need' or l['Dictionary'] == 'in_progress' }
    data[:dictionary] = [dictionary.count, dictionary.sum{ |l| l[:pop] }]

    misc_needs = (jesus_film + songs + literacy + parivartan + dictionary).uniq
    data[:misc_needs] = [misc_needs.count, misc_needs.sum{ |l| l[:pop] }]

    jesus_film_done = language_data.select do |l|
      l['Jesus Film'] == 'completed' or
          l['Jesus Film'] == 'further_needs_expressed' or
          l['Jesus Film'] == 'further_work_in_progress'
    end
    data[:jesus_film_done] = [jesus_film_done.count, jesus_film_done.sum{ |l| l[:pop] }]

    obs_done = language_data.select do |l|
      l['Oral Bible Stories'] == 'completed' or
          l['Oral Bible Stories'] == 'further_needs_expressed' or
          l['Oral Bible Stories'] == 'further_work_in_progress'
    end
    data[:obs_done] = [obs_done.count, obs_done.sum{ |l| l[:pop] }]

    songs_done = language_data.select do |l|
      l['Songs Set'] == 'completed' or
          l['Songs Set'] == 'further_needs_expressed' or
          l['Songs Set'] == 'further_work_in_progress'
    end
    data[:songs_done] = [songs_done.count, songs_done.sum{ |l| l[:pop] }]

    literacy_done = language_data.select do |l|
      l['LCI Literacy Classes'] == 'completed' or
          l['LCI Literacy Classes'] == 'further_needs_expressed' or
          l['LCI Literacy Classes'] == 'further_work_in_progress'
    end
    data[:literacy_done] = [literacy_done.count, literacy_done.sum{ |l| l[:pop] }]

    parivartan_done = language_data.select do |l|
      l['LCI Parivartan Groups'] == 'completed' or
          l['LCI Parivartan Groups'] == 'further_needs_expressed' or
          l['LCI Parivartan Groups'] == 'further_work_in_progress'
    end
    data[:parivartan_done] = [parivartan_done.count, parivartan_done.sum{ |l| l[:pop] }]

    dictionary_done = language_data.select do |l|
      l['Dictionary'] == 'completed' or
          l['Dictionary'] == 'further_needs_expressed' or
          l['Dictionary'] == 'further_work_in_progress'
    end
    data[:dictionary_done] = [dictionary_done.count, dictionary_done.sum{ |l| l[:pop] }]

    data
  end

  def board_report_row(report_data, row_index, name, total_lang, total_pop)
    row = %Q(
    <tr>
      <td class="mdl-data-table__cell--non-numeric">#{name}</td>
      <td>#{report_data[row_index][0]}#{pie_chart_element(report_data[row_index][0].to_f / total_lang.to_f * 100.0)}</td>
      <td>#{number_with_delimiter(report_data[row_index][1], delimiter: ',')}</td>
    )
    if total_pop > 0
      percent = report_data[row_index][1].to_f / total_pop.to_f * 100.0
      row += "\n<td>#{number_with_precision(percent, precision: 3, significant: true)}%#{pie_chart_element(percent)}</td>"
    end
    row + "\n</tr>"
  end

  def board_report_rows(report_data, row_hash, total_lang, total_pop)
    rows = ''
    row_hash.each do |row_index, name|
      rows += "\n#{board_report_row(report_data, row_index, name, total_lang, total_pop)}"
    end
    rows
  end

  def combined_board_report_row(report_data, row_indices, name, total_lang, total_pop)
    combined_total_lang = report_data.select{ |key,_| row_indices.include? key }.sum{ |k,v| v[0] }
    combined_total_pop = report_data.select{ |key,_| row_indices.include? key }.sum{ |k,v| v[1] }
    row = %Q(
    <tr>
      <th class="mdl-data-table__cell--non-numeric">#{name}</th>
      <th>#{combined_total_lang}#{pie_chart_element(combined_total_lang.to_f / total_lang.to_f * 100.0)}</th>
      <th>#{number_with_delimiter(combined_total_pop, delimiter: ',')}</th>
    )
    if total_pop > 0
      percent = combined_total_pop.to_f / total_pop.to_f * 100.0
      row += "\n<th>#{number_with_precision(percent, precision: 3, significant: true)}%#{pie_chart_element(percent)}</th>"
    end
    row + "\n</tr>"
  end

  def pie_chart_element(percent)
    chart_type = (percent < 50) ? 'low' : 'high'
    percent -= 50 if percent >= 50
    pie_uid = SecureRandom.uuid
    pie_style = "<style>#pie-#{pie_uid}:before{ transform: rotate(#{percent / 100.0}turn); }</style>"
    pie_html = "<div id=\"pie-#{pie_uid}\" class=\"pie-chart #{chart_type} #{@chart_style_need ? 'need' : 'complete' }\"></div>"
    "#{pie_style}#{pie_html}"
  end

end
