class User::Updater

  attr_reader :instance

  def initialize(user)
    @instance = user
  end

  def update_user(params)
    speaks = params.delete(:speaks)
    geo_states = params.delete(:geo_states)
    result = @instance.update_attributes(params)
    if speaks
      @instance.spoken_languages.clear
      speaks.each do |lang_id|
        @instance.spoken_languages << Language.find(lang_id)
      end
    end
    if @instance.mother_tongue
      @instance.spoken_languages << @instance.mother_tongue unless @instance.spoken_languages.includes @instance.mother_tongue
    end
    if geo_states
      @instance.geo_states.clear
      geo_states.each do |geo_state_id|
        @instance.geo_states << GeoState.find(geo_state_id)
      end
    end
    return result
  end

end