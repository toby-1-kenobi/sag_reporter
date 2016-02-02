class GeoStatesController < ApplicationController

  before_action :require_login

  autocomplete :district, :name

  def get_autocomplete_items(parameters)
    super(parameters).where(:geo_state_id => params[:geo_state_id])
  end

end
