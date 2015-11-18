class User::Factory

  attr_reader :instance

  def build_user(params)
    speaks = params.delete(:speaks)
    geo_states = params.delete(:geo_states)
    begin
      @instance = User.new(params)
    rescue
      return false
    else
      if speaks
        speaks.each do |lang_id|
          @instance.spoken_languages << Language.find(lang_id)
        end
      end
      if @instance.mother_tongue
        @instance.spoken_languages << @instance.mother_tongue unless @instance.spoken_languages.includes @instance.mother_tongue
      end
      if geo_states
        geo_states.each do |geo_state_id|
          @instance.geo_states << GeoState.find(geo_state_id)
        end
      end
      return true
    end
  end

  def create_user(params)
    if build_user(params) and @instance.valid?
      return @instance.save
    else
      return false
    end
  end

  def update_user(user, params)
    @instance = user
    speaks = params.delete(:speaks)
    geo_states = params.delete(:geo_states)
    if @instance.update_attributes(params)
      @instance.spoken_languages.clear
      if speaks
        speaks.each do |lang_id|
          @instance.spoken_languages << Language.find(lang_id)
        end
      end
      @instance.spoken_languages << @instance.mother_tongue unless @instance.spoken_languages.includes @instance.mother_tongue
      @instance.geo_states.clear
      if geo_states
        geo_states.each do |geo_state_id|
          @instance.geo_states << GeoState.find(geo_state_id)
        end
      end
      return true
    else
      return false
    end
  end

end