class ProjectsController < ApplicationController

  before_action :require_login

  before_action only: [:create, :destroy, :update] do
    head :forbidden unless logged_in_user.admin? or logged_in_user.zone_admin?
  end

  def create
    @project = Project.create(project_params)
    respond_to :js
  end

  def destroy
    @project = Project.find(params[:id])
    if @project
      @project.destroy
      respond_to :js
    else
      head :not_found
    end
  end

  def edit
    @project = Project.includes(:geo_states).find(params[:id])
    respond_to :js
  end

  def update
    @project = Project.find(params[:id])
    @project.update_attributes(project_params)
    respond_to :js
  end

  def show
    @project = Project.find(params[:id])
    respond_to :js
  end

  def set_language
    @project = Project.find(params[:id])
    @state_language = StateLanguage.find(params[:state_language])
    if params["sl-#{@state_language.id}"].present?
      @state_language.update_attribute(:project, true)
      @project.state_languages << @state_language unless @project.state_languages.include? @state_language
    else
      @project.state_languages.delete @state_language
      @state_language.update_attribute(:project, false) unless (@state_language.projects.any? or @state_language.progress_updates.any?)
    end
    respond_to :js
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
