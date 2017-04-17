class EditsController < ApplicationController

  before_action :require_login

  # Only users who are curators can curate edits
  before_action only: [:curate] do
    redirect_to root_path unless logged_in_user.curated_states.any? or logged_in_user.national_curator?
  end

  before_action only: [:approve, :reject] do
    @edit = Edit.find params[:id]
    head :forbidden unless User.curating(@edit).include? logged_in_user
  end

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

  def curate
    @edits = Edit.includes(:user, :geo_states).pending.for_curating(logged_in_user).order(:created_at)
    if logged_in_user.national_curator?
      @national_edits = Edit.pending_national_approval
    else
      @national_edits = false
    end
  end

  def my
    @edits = logged_in_user.edits.includes(:user, :geo_states).order(:created_at)
  end

  def approve
    @edit.approve(logged_in_user)
    respond_to do |format|
      format.js {render 'change'}
    end
  end

  def reject
    @edit.reject(logged_in_user)
    respond_to do |format|
      format.js {render 'change'}
    end
  end

  def destroy
    @edit = Edit.find params[:id]
    head :forbidden unless logged_in_user?(@edit.user)
    @edit.destroy
    respond_to do |format|
      format.js
    end
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
