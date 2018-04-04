class ProjectsController < ApplicationController

  before_action :require_login

  before_action only: [:create] do
    head :forbidden unless logged_in_user.admin?
  end

  def index
    redirect_to root_path unless logged_in_user.admin?
    @projects = Project.all
  end

  def create
    @project = Project.create(project_params)
    respond_to :js
  end

  def delete
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
