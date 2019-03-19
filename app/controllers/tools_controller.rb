class ToolsController < ApplicationController

  before_action :require_login

  def new
    @tool = Tool.new
    render 'edit'
  end

  def create
    @tool = Tool.new(tool_params)
    @tool.creator = logged_in_user
    render 'edit' unless @tool.save
  end

  def edit
    @tool = Tool.find params[:id]
  end

  def update
    @tool = Tool.find params[:id]
    if @tool.update_attributes(tool_params)
      render 'rerender'
    else
      render 'edit'
    end
  end

  def destroy
    @tool = Tool.find params[:id]
    @tool.deleted!
    render 'rerender'
  end

  private

  def tool_params
    params.require(:tool).permit(
        :description,
        :language_id,
        :url,
        :finish_line_marker_id,
        product_category_ids: []
    )
  end

end
