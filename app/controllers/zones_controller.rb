class ZonesController < ApplicationController

  before_action :require_login

  def index
    @zones = Zone.all
  end

  def show
    @zone = Zone.find params[:id]
    @languages = Language.includes({geo_states: :zone}, :family, :finish_line_progresses).where(geo_states: {zone: @zone})
  end

  def nation
    @languages = Language.includes(:family, :finish_line_progresses).all
  end

end
