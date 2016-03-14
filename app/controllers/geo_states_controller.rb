class GeoStatesController < ApplicationController

  before_action :require_login

  autocomplete :district, :name

  def get_autocomplete_items(parameters)
    super(parameters).where(:geo_state_id => params[:geo_state_id])
  end

  def get_totals_chart
    @geo_state = GeoState.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

end
