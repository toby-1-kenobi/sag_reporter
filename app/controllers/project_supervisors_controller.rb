class ProjectSupervisorsController < ApplicationController

  def create
    @project = Project.find params[:project]
    ps = ProjectSupervisor.create(project: @project, user_id: params[:supervisor], role: 0)
    Rails.logger.error("Failed to add supervisor to project: #{ps.errors.full_messages.to_sentence}") unless ps.persisted?
    respond_to do |format|
      format.js { render :template => "projects/add_supervisor" }
    end
  end

  def destroy
    ps = ProjectSupervisor.find(params[:id])
    ps.destroy
    respond_to :js
  end

end
