class EditsController < ApplicationController

  before_action :require_login

  # Only users who are curators can curate edits
  before_action only: [:curate] do
    redirect_to root_path unless logged_in_user.curated_states.any? or logged_in_user.national_curator?
  end

  before_action only: [:approve, :reject] do
    @edit = Edit.find params[:id]
    head :forbidden unless (logged_in_user.national_curator? or User.curating(@edit).include? logged_in_user)
  end

  def create
    @element_id = params[:element_id]
    @edit = Edit.new(edit_params)
    @edit.user = logged_in_user
    if @edit.user.national_curator?
      @edit.status = :auto_approved
    elsif @edit.model_klass_name == 'Language'
      logger.debug "double_approve_fields: #{double_approve_fields['Language']}"
      logger.debug "attribute: #{@edit.attribute_name}"
      logger.debug "double: #{double_approve_fields['Language'].include? @edit.attribute_name}"
      if double_approve_fields['Language'].include? @edit.attribute_name
        @edit.status = :pending_double_approval
      else
        @edit.status = :pending_single_approval
      end
    else
      @edit.status = :auto_approved
    end
    if @edit.save
      @edit.apply if @edit.auto_approved?
    end
    respond_to do |format|
      format.js
    end
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
      format.js {render 'curate_edit'}
    end
  end

  def reject
    @edit.reject(logged_in_user)
    respond_to do |format|
      format.js {render 'curate_edit'}
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

  def add_creator_comment
    @edit = Edit.find params[:edit_id]
    @edit.creator_comment = params[:comment]
    @edit.save
    respond_to do |format|
      format.js {render 'change'}
    end
  end

  def add_curator_comment
    @edit = Edit.find params[:edit_id]
    @edit.curator_comment = params[:comment]
    @edit.save
    respond_to do |format|
      format.js {render 'change'}
    end
  end

  private

  def edit_params
    params.require(:edit).permit(
        :model_klass_name,
        :record_id,
        :attribute_name,
        :old_value,
        :new_value,
        :relationship
    )
  end

  def double_approve_fields
    {
        'Language' => %w(
          name iso population location translating_organisations
          translation_info translation_consultants translation_interest
          translator_background translation_local_support
        )
    }
  end

end
