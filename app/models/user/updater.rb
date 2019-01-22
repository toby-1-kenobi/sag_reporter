class User::Updater

  attr_reader :instance

  def initialize(user)
    @instance = user
  end

  def update_user(params, skip_confirm_email = false)
    PaperTrail.request.enabled = false
    champion = params.delete(:champion)
    @instance.championed_languages.clear
    speaks = params.delete(:speaks)
    @instance.spoken_languages.clear
    geo_states = params.delete(:geo_states)
    curated_states = params.delete(:curated_states)
    @instance.curated_states.clear
    PaperTrail.request.enabled = true
    if skip_confirm_email
      # if we skip sending the confirmation email, we must make the email confirmed if it's there
      if params[:email].present?
        params[:email_confirmed] = true
      end
      User.skip_callback(:save, :after, :send_confirmation_email)
      result = @instance.update_attributes(params)
    else
      result = @instance.update_attributes(params)
    end
    PaperTrail.request.enabled = false
    if champion
      champion.each do |lang_id|
        @instance.championed_languages << Language.find(lang_id)
      end
    end
    if speaks
      speaks.each do |lang_id|
        @instance.spoken_languages << Language.find(lang_id)
      end
    end
    if geo_states
      @instance.geo_states.clear
      geo_states.each do |geo_state_id|
        @instance.geo_states << GeoState.find(geo_state_id)
      end
    end
    if curated_states
      curated_states.each do |state_id|
        @instance.curated_states << GeoState.find(state_id)
      end
    end
    PaperTrail.request.enabled = true
    return result
  end

end