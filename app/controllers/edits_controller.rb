class EditsController < ApplicationController

  before_action :require_login

  def create
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
    response = Hash.new
    if @edit.save
      response[:success] = true
      if @edit.auto_approved?
        response[:success] = @edit.apply
        response[:error] = @edit.record_errors unless response[:success]
      end
    else
      response[:success] = false
      response[:error] = @edit.errors.full_messages.to_sentence
    end
    response[:approval] = @edit.status
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
