class EditsController < ApplicationController

  before_action :require_login

  def create
    @element_id = params[:element_id]
    @edit = Edit.new(edit_params)
    @edit.user = logged_in_user
    if @edit.model_klass_name == 'Language'
      if ['name', 'iso', 'population', 'location'].include? @edit.attribute_name
        @edit.pending_double_approval!
      else
        @edit.pending_single_approval!
      end
    else
      @edit.auto_approved!
    end
    if @edit.save
      @edit.apply if @edit.auto_approved?
    end
    respond_to do |format|
      format.js
    end
  end

  def index
  end

  def show
  end

  private

  def edit_params
    params.require(:edit).permit(
        :model_klass_name,
        :record_id,
        :attribute_name,
        :old_value,
        :new_value
    )
  end

end
