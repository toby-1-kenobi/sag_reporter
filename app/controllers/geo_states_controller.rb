class GeoStatesController < ApplicationController

  before_action :require_login
  before_action :find_state, except: [:get_autocomplete_items]

  autocomplete :district, :name, full: true

  def show
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:geo_state_id => params[:geo_state_id])
  end

  def get_totals_chart
    respond_to do |format|
      format.js
    end
  end

  def get_outcome_area_chart
    @outcome_area = Topic.find(params[:topic_id])
    respond_to do |format|
      format.js
    end
  end

  def get_combined_languages_chart
    respond_to do |format|
      format.js
    end
  end

  def bulk_assess

  end

  private

  def find_state
    @geo_state = GeoState.find(params[:id])
  end

end