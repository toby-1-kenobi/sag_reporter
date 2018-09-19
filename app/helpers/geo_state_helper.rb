module GeoStateHelper
  def dashboard_project_states(project, user)
    if user.national?
      GeoState.order(:name)
    else
      # all the states that fall in either the user's zone or the project's zone
      zones = user.zones.pluck(:id).concat(project.zones.pluck(:id))
      GeoState.where(zone: zones).order(:name)
    end
  end
end
