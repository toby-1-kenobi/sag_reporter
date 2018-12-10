class MinistriesController < ApplicationController

  before_action :require_login

  def projects_overview
    @ministry = Ministry.includes(:deliverables).find params[:id]
    @zones = Zone.includes(:aggregate_ministry_outputs, :ministry_outputs)
    @quarter = params[:quarter]
    respond_to :js
  end

end
