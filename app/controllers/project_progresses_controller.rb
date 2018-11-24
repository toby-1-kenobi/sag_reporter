class ProjectProgressesController < ApplicationController

  before_action :require_login

  def update
    @project_progress = ProjectProgress.find params[:id]
    @project_progress.update_attributes(project_progress_params)
    respond_to :js
  end

  def create
    @project_progress = ProjectProgress.create(project_progress_params)
    if @project_progress.errors.any?
      Rails.logger.error @project_progress.errors.full_messages
    end
    respond_to :js
  end

  private

  def project_progress_params
    params.require(:project_progress).permit(
        [
            :comment,
            :approved,
            :month,
            :progress,
            :project_stream_id
        ]
    )
  end

end
