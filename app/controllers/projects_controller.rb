class ProjectsController < ApplicationController

  before_action :require_login

  before_action only: [:create, :destroy] do
    head :forbidden unless logged_in_user.admin? or logged_in_user.zone_admin?
  end

  def create
    @project = Project.create(name: "#{Faker::Color.color_name} #{Faker::Lorem.word}".titleize)
    respond_to :js
  end

  def destroy
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    if @project
      @project.destroy
      respond_to :js
    else
      head :not_found
    end
  end

  def edit
    @project = Project.includes(:geo_states).find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    respond_to :js
  end

  def teams
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_view_project?(@project)
    project_teams = ChurchTeam.active.in_project(@project)
    @team_names = {}
    project_teams.includes(:organisation).find_each{ |pt| @team_names[pt.id] = pt.full_name }
    @teams = project_teams.pluck_to_struct :id, :state_language_id
    @church_min = ChurchMinistry.active.where(church_team_id: @teams.map{ |t| t[0] }).pluck_to_struct :id, :church_team_id, :ministry_id
    @fac_feedbacks = FacilitatorFeedback.not_empty.where(church_ministry_id: @church_min.map{ |cm| cm[0] }).pluck_to_struct :church_ministry_id, :progress, :report_approved, :month
    respond_to :js
  end

  def team_deliverables
    @project = Project.includes(:ministries).find(params[:id])
    head :forbidden unless logged_in_user.can_view_project?(@project)
    @team = ChurchTeam.active.includes(:ministries, { state_language: [:language, :geo_state] }).find(params[:team_id])
    @common_ministries = @team.ministries.where(id: @project.ministries)
    respond_to :js
  end

  def facilitators
    @project = Project.includes(language_streams: [:facilitator, {state_language: [:language, :geo_state]}, {ministry: {deliverables: :aggregate_ministry_outputs}}]).find(params[:id])
    head :forbidden unless logged_in_user.can_view_project?(@project)
    Rails.logger.debug "outputs: #{@outputs}"
    respond_to :js
  end

  def quarterly
    @project = Project.find(params[:id])
    respond_to :js
  end

  def edit_responsible
    @project = Project.includes(:geo_states).find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    respond_to :js
  end

  def update
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    @project.update_attributes(project_params)
    respond_to :js
  end

  def show
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_view_project?(@project)
    respond_to :js
  end

  def set_language
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
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
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    @stream = Ministry.find(params[:ministry])
    if params["stream-#{@stream.id}"].present?
      @project.ministries << @stream unless @project.ministries.include? @stream
    else
      @project.ministries.delete @stream
    end
    respond_to :js
  end

  def add_facilitator
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    @language_stream = LanguageStream.find_or_create_by(
        ministry_id: params[:stream],
        state_language_id: params[:state_language],
        facilitator_id: params[:facilitator],
        project_id: params[:id]
    )
    respond_to :js
  end

  def targets_by_language
    @project = Project.find(params[:id])
    head :forbidden unless logged_in_user.can_edit_project?(@project)
    @state_language = StateLanguage.find(params[:state_language])
    respond_to :js
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
