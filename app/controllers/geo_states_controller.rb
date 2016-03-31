class GeoStatesController < ApplicationController

  before_action :require_login

  autocomplete :district, :name, full: true

  def get_autocomplete_items(parameters)
    super(parameters).where(:geo_state_id => params[:geo_state_id])
  end

  def get_totals_chart
    @geo_state = GeoState.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def get_outcome_area_chart
    @geo_state = GeoState.find(params[:id])
    @outcome_area = Topic.find(params[:topic_id])
    respond_to do |format|
      format.js
    end
  end

  def get_combined_languages_chart
    @geo_state = GeoState.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

end