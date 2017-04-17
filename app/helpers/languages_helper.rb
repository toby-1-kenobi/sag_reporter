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

end
