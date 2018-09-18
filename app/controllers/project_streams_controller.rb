class ProjectStreamsController < ApplicationController
  def set_supervisor
    @project_stream = ProjectStream.find(params[:id])
    supervisor = User.find(params[:supervisor])
    @project_stream.supervisor = supervisor
    @project_stream.save
    respond_to :js
  end
end
