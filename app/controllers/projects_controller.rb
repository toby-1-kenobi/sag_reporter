class ProjectsController < ApplicationController

  before_action :require_login

  before_action except: [:show] do
    head :forbidden unless logged_in_user.can_manage_projects?
  end
  before_action only: [:show] do
    head :forbidden unless logged_in_user.can_view_projects?
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

  def teams
    @project = Project.find(params[:id])
    @teams = ChurchTeam.in_project(@project)
    respond_to :js
  end

  def team_deliverables
    @project = Project.includes(:ministries).find(params[:id])
    @team = ChurchTeam.includes(:ministries, { state_language: [:language, :geo_state] }).find(params[:team_id])
    @common_ministries = @team.ministries.where(id: @project.ministries)
    respond_to :js
  end

  def facilitators
    @project = Project.includes(language_streams: [:facilitator, {state_language: [:language, :geo_state]}, {ministry: {deliverables: :aggregate_ministry_outputs}}]).find(params[:id])
    @outputs = {}
    @project.language_streams.each do |lang_stream|
      lang_stream.ministry.deliverables.facilitator.each do |deliverable|
        @outputs[deliverable.id] ||= {}
        deliverable.aggregate_ministry_outputs.where(state_language: @project.state_languages).where('month >= ?', 6.months.ago.strftime("%Y-%m")).each do |amo|
          @outputs[deliverable.id][amo.state_language_id] ||= {}
          @outputs[deliverable.id][amo.state_language_id][amo.creator_id] ||= {}
          @outputs[deliverable.id][amo.state_language_id][amo.creator_id][amo.month] ||= {}
          @outputs[deliverable.id][amo.state_language_id][amo.creator_id][amo.month][amo.actual] = amo.value
        end
      end
    end
    Rails.logger.debug "outputs: #{@outputs}"
    respond_to :js
  end

  def edit_responsible
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
        facilitator_id: params[:facilitator],
        project_id: params[:id]
    )
    respond_to :js
  end

  def targets_by_language
    @project = Project.find(params[:id])
    @state_language = StateLanguage.find(params[:state_language])
    respond_to :js
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
