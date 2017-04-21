class ZonesController < ApplicationController

  before_action :require_login

  def index
    @zones = Zone.all
  end

  def show
    @zone = Zone.find params[:id]
  end

  def nation

  end

end
