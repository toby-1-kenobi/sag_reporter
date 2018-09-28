class ProjectSupervisorsController < ApplicationController

  def create
    @project = Project.find params[:project]
    ps = ProjectSupervisor.create(project: @project, user_id: params[:supervisor], role: 0)
    Rails.logger.error("Failed to add supervisor to project: #{ps.errors.full_messages.to_sentence}") unless ps.persisted?
    respond_to do |format|
      format.js { render :template => "projects/refresh_supervisor_list" }
    end
  end

  def destroy
    ps = ProjectSupervisor.find(params[:id])
    @project = ps.project
    ps.destroy
    respond_to do |format|
      format.js { render :template => "projects/refresh_supervisor_list" }
    end
  end

  def update
    ps = ProjectSupervisor.find(params[:id])
    ps.update_attributes(project_supervisor_params)
    @project = ps.project
    respond_to do |format|
      format.js { render :template => "projects/refresh_supervisor_list" }
    end
  end

  private

  def project_supervisor_params
    params.require(:project_supervisor).permit([:role])
  end


end
