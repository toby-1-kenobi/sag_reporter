class DistrictsController < ApplicationController

  before_action :require_login

  autocomplete :sub_district, :name

  def get_autocomplete_items(parameters)
    super(parameters).where(:district_id => params[:district_id])
  end
end
