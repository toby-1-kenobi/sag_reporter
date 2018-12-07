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
        pdf = QuarterlyReportPdf.new(@project, @sub_project, @quarter)
        send_data pdf.render, filename: "#{project_name}_quarterly_report.pdf", type: 'application/pdf'
      end
    end
  end

  private

  def sub_project_params
    params.require(:sub_project).permit(:project_id, :name)
  end

end
