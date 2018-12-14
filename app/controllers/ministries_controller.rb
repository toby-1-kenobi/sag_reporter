class MinistriesController < ApplicationController

  before_action :require_login

  def projects_overview
    @ministry = Ministry.includes(deliverables: { short_form: :translations }).find params[:id]
    @zones = Zone.includes(:aggregate_ministry_outputs, :ministry_outputs, :quarterly_targets)
    @quarter = params[:quarter]
    respond_to :js
  end

end
