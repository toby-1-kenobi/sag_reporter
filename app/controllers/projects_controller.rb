class ProjectsController < ApplicationController

  before_action :require_login

  def index
    redirect_to root_path unless logged_in_user.admin?
    @projects = Project.all
  end

  def create
  end

  def delete
  end
end
