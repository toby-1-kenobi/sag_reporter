class EditsController < ApplicationController

  before_action :require_login

  # Only users who are curators can curate edits
  before_action only: [:curate] do
    redirect_to root_path unless logged_in_user.curated_states.any? or logged_in_user.national_curator? or logged_in_user.forward_planning_curator?
  end

  before_action only: [:approve, :reject] do
    @edit = Edit.find params[:id]
    head :forbidden unless logged_in_user.can_curate?(@edit)
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
    @edits = Edit.includes(:user, :geo_states).pending.for_curating(logged_in_user).order(created_at: :desc)
    if logged_in_user.national_curator?
      @national_edits = Edit.pending_national_approval
    else
      @national_edits = false
    end
    if logged_in_user.forward_planning_curator?
      @forward_planning_edits = Edit.pending_forward_planning_approval
    else
      @forward_planning_edits = false
    end
  end

  def my
    @edits = logged_in_user.edits.includes(:user, :geo_states).order(created_at: :desc)
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
    e_params = params.require(:edit).permit(
        :model_klass_name,
        :record_id,
        :attribute_name,
        :old_value,
        :new_value,
        :relationship
    )
    # for edits of boolean attributes we need to fill in missing values with '0'
    if e_params[:model_klass_name].constantize.columns_hash[e_params[:attribute_name]].type == :boolean
      e_params[:old_value] ||= '0'
      e_params[:new_value] ||= '0'
    end
    e_params
  end

  def double_approve_fields
    {
        'Language' => %w(
          name iso population location translating_organisations
          translation_info translation_consultants translation_interest
          translator_background translation_local_support bible_first_published
          bible_last_published nt_first_published nt_last_published
          portions_first_published portions_last_published
        )
    }
  end

end
