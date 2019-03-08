class ToolsController < ApplicationController

  before_action :require_login

  def create
  end

  def update
  end

  def destroy
    @tool = Tool.find params[:id]
    @tool.deleted!
    respond_to do |format|
      format.js { render 'rerender' }
    end
  end

end
