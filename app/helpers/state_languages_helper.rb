module StateLanguagesHelper

  def dashboard_state_languages(dashboard_type)
    case dashboard_type
    when :state
      @geo_state.state_languages.includes(:language).order('languages.name')
    when :zone
      @zone.state_languages.includes(:language).order('languages.name')
    else
      StateLanguage.all.includes(:language).order('languages.name')
    end
  end

end
