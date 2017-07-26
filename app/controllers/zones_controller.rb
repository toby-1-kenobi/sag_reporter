class ZonesController < ApplicationController

  before_action :require_login

  def index
    @zones = Zone.all
  end

  def show
    @zone = Zone.find params[:id]
    @languages = Language.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user).where(geo_states: {zone: @zone})
    @geo_states = @zone.geo_states
    @geo_states = @geo_states.where(id: logged_in_user.geo_states) unless logged_in_user.national?
  end

  def nation
    @languages = Language.includes(:family, {finish_line_progresses: :finish_line_marker}).all
  end

end
