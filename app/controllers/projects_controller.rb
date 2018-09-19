class ProjectsController < ApplicationController

  before_action :require_login

  before_action only: [:create, :destroy, :update] do
    head :forbidden unless logged_in_user.admin? or logged_in_user.zone_admin?
  end

  def create
    @project = Project.create(name: "#{Faker::Color.color_name} #{Faker::Lorem.word}".titleize)
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

  def set_stream
    @project = Project.find(params[:id])
    @stream = Ministry.find(params[:ministry])
    if params["stream-#{@stream.id}"].present?
      @project.ministries << @stream unless @project.ministries.include? @stream
    else
      @project.ministries.delete @stream
    end
    respond_to :js
  end

  def add_facilitator
    @language_stream = LanguageStream.find_or_create_by(
        ministry_id: params[:stream],
        state_language_id: params[:state_language],
        facilitator_id: params[:facilitator]
    )
    @language_stream.update_attribute(:project_id, params[:id])
    respond_to :js
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
