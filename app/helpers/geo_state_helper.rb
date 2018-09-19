module GeoStateHelper
  def dashboard_project_states(project, dashboard_type)
    Rails.logger.debug("dashboard states #{dashboard_type.to_s} | #{@dashboard_type.to_s}")
    case dashboard_type
    when :state
      if project.geo_states.uniq.count <= 1
        GeoState.where(id: @geo_state.id)
      elsif project.zones.count == 1
        project.zones.uniq.first.geo_states.order(:name)
      else
        GeoState.order(:name)
      end
    when :zone
      if project.zones.uniq.count <= 1
        Rails.logger.debug('single zone')
        @zone.geo_states.order(:name)
      else
        GeoState.order(:name)
      end
    else
      GeoState.order(:name)
    end
  end
end
