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
      lang.finish_line_progresses.each do |flp|
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

  def get_transformation(zone)
    # for each project language get the aggregated data for both dates
    transformations = Hash.new
    # join progress updates to only include languages that have had baseline set.
    StateLanguage.in_project.joins(:progress_updates).includes(:language, {geo_state: :zone}, {:language_progresses =>[{:progress_marker => :topic}, :progress_updates]}).uniq.find_each do |state_language|
      transformations[state_language] = state_language.transformation_data(logged_in_user)
    end
    transformations
  end

  def get_outcome_area()
    @outcome_area_colours = Hash.new
    Topic.find_each{ |oa| @outcome_area_colours[oa.name] = oa.colour }
    @outcome_area_colours
  end
end
