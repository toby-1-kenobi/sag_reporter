class SubProjectsController < ApplicationController

  before_action :require_login

  def create
    @sub_project = SubProject.create(sub_project_params)
    Rails.logger.error(@sub_project.errors.full_messages) unless @sub_project.persisted?
    respond_to :js
  end

  def destroy
    @sub_project_id = params[:id]
    SubProject.find(@sub_project_id).destroy
    respond_to :js
  end

  def quarterly_report
    if SubProject.exists?(params[:id])
      @sub_project = SubProject.includes(:project).find(params[:id])
      @project = @sub_project.project
    else
      # if no sub-project has been selected the id will be the project id prefixed with a single character
      @project = Project.find(params[:id][1..-1])
    end
    respond_to :js
  end

  def populate_stream_headers
    if SubProject.exists?(params[:id])
      sub_project = SubProject.includes(:project).find(params[:id])
    else
      # if no sub-project has been selected the id will be the project id prefixed with a single character
      project = Project.find(params[:id][1..-1])
    end
    @state_language_id = params[:state_language]
    if sub_project
      streams = sub_project.project.ministries.to_a.select {|s| sub_project.language_streams.exists?(state_language_id: @state_language_id, ministry_id: s.id)}
    else
      streams = project.ministries
    end
    @qes = {}
    streams.each do |stream|
      if sub_project
        sp_id = sub_project.id
        p_id = sub_project.project_id
      else
        sp_ids = project.language_streams.where(state_language_id: @state_language_id, ministry_id: stream.id).pluck(:sub_project_id).uniq
        sp_id = sp_ids.length == 1 ? sp_ids[0] : nil
        p_id = project.id
      end
       qe = QuarterlyEvaluation.find_by(
          project_id: p_id,
          sub_project_id: sp_id,
          state_language_id: @state_language_id,
          ministry_id: stream.id,
          quarter: params[:quarter]
      )
      @qes[stream.id] = qe if qe
    end
    respond_to :js
  end

  def populate_lang_headers
    if SubProject.exists?(params[:id])
      sub_project = SubProject.includes(:project).find(params[:id])
    else
      # if no sub-project has been selected the id will be the project id prefixed with a single character
      project = Project.find(params[:id][1..-1])
    end
    @stream_id = params[:stream]
    if sub_project
      state_languages = sub_project.project.state_languages.to_a.select {|sl| sub_project.language_streams.exists?(state_language_id: sl.id, ministry_id: @stream_id)}
    else
      state_languages = project.state_languages
    end
    @qes = {}
    state_languages.each do |state_language|
      if sub_project
        sp_id = sub_project.id
        p_id = sub_project.project_id
      else
        sp_ids = project.language_streams.where(state_language_id: state_language.id, ministry_id: @stream_id).pluck(:sub_project_id).uniq
        sp_id = sp_ids.length == 1 ? sp_ids[0] : nil
        p_id = project.id
        end
      qe = QuarterlyEvaluation.find_by(
          project_id: p_id,
          sub_project_id: sp_id,
          state_language_id: state_language.id,
          ministry_id: @stream_id,
          quarter: params[:quarter]
      )
      @qes[state_language.id] = qe if qe
    end
    respond_to :js
  end

  def stream_summary
    if SubProject.exists?(params[:id])
      sub_project = SubProject.includes(:project).find(params[:id])
    else
      # if no sub-project has been selected the id will be the project id prefixed with a single character
      project = Project.find(params[:id][1..-1])
    end
    @stream = Ministry.find params[:stream]

    # get church team outputs
    if sub_project
      state_languages = sub_project.project.state_languages.pluck(:id).select {|sl_id| sub_project.language_streams.exists?(state_language_id: sl_id, ministry_id: @stream.id)}
    else
      state_languages = project.state_languages.pluck :id
    end
    @quarter = params[:quarter]
    church_mins = ChurchMinistry.joins(:church_team).
        where(church_teams: {state_language_id: state_languages}, ministry: @stream)
    @outputs = MinistryOutput.where(actual: true, church_ministry: church_mins)

    # get facilitator outputs
    if sub_project
      lang_streams = LanguageStream.where(sub_project: sub_project, state_language_id: state_languages, ministry: @stream)
    else
      lang_streams = LanguageStream.where(project: project, state_language_id: state_languages, ministry: @stream)
    end
    @aggregate_outputs = AggregateMinistryOutput.
        where(actual: true, state_language_id: state_languages, creator_id: lang_streams.pluck(:facilitator_id))
    @targets = QuarterlyTarget.includes(:deliverable).where(state_language_id: state_languages, deliverables: {ministry_id: @stream.id}).to_a
    respond_to :js
  end

  def download_quarterly_report
    if SubProject.exists?(params[:id])
      @sub_project = SubProject.includes(quarterly_evaluations: [:state_language, ministry: :deliverables]).find(params[:id])
      @project = @sub_project.project
    else
      # if no sub-project has been selected the id will be the project id prefixed with a single character
      @project = Project.includes(quarterly_evaluations: [:state_language, ministry: :deliverables]).find(params[:id][1..-1])
    end
    project_name = @sub_project ? @sub_project.name : @project.name
    @quarter = params[:quarter]
    respond_to do |format|
      format.pdf do
        pdf = QuarterlyReportPdf.new(@project, @sub_project, @quarter, view_context)
        send_data pdf.render, filename: "#{project_name}_quarterly_report.pdf", type: 'application/pdf'
      end
    end
  end

  private

  def sub_project_params
    params.require(:sub_project).permit(:project_id, :name)
  end

end
