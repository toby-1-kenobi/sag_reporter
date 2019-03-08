class ToolsController < ApplicationController

  before_action :require_login

  def edit
    @tool = Tool.find params[:id]
  end

  def create
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
