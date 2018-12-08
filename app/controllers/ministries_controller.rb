class MinistriesController < ApplicationController

  before_action :require_login

  def projects_overview
    @ministry = Ministry.includes(:deliverables).find params[:id]
    @zones = Zone.includes(state_languages: [:aggregate_ministry_outputs, church_teams: {church_ministries: :ministry_outputs}])
    respond_to :js
  end

end
