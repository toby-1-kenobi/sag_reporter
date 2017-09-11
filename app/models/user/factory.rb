class User::Factory

  attr_reader :instance

  def build_user(params)
    champion = params.delete(:champion)
    speaks = params.delete(:speaks)
    geo_states = params.delete(:geo_states)
    curated_states = params.delete(:curated_states)
    begin
      @instance = User.new(params)
    rescue
      return false
    else
      if champion
        @instance.championed_languages.clear
        champion.each do |lang_id|
          @instance.championed_languages << Language.find(lang_id)
        end
      end
      if speaks
        speaks.each do |lang_id|
          @instance.spoken_languages << Language.find(lang_id)
        end
      end
      if @instance.mother_tongue
        @instance.spoken_languages << @instance.mother_tongue unless @instance.spoken_languages.include? @instance.mother_tongue
      end
      if geo_states
        geo_states.each do |geo_state_id|
          @instance.geo_states << GeoState.find(geo_state_id)
        end
      end
      if curated_states
        curated_states.each do |geo_state_id|
          @instance.curated_states << GeoState.find(geo_state_id)
        end
      end
      return true
    end
  end

  # Only admin users can crete new users and we skip the email confirmation
  # when the current user is admin, so it seems this branching logic is redundant
  def create_user(params, skip_confirm_email = false)
    if build_user(params) and @instance.valid?
      if skip_confirm_email
        # if we skip sending the confirmation email, we must make the email confirmed if it's there
        if @instance.email.present?
          @instance.email_confirmed = true
        end
        User.skip_callback(:save, :after, :send_confirmation_email)
      end
      return @instance.save
    else
      return false
    end
  end

end