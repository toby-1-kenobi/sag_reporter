class ProjectsController < ApplicationController

  before_action :require_login

  before_action only: [:create, :destroy] do
    head :forbidden unless logged_in_user.admin?
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

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
