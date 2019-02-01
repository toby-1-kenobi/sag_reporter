class TranslationProgressesController < ApplicationController

  before_action :require_login

  def create
  end

  def destroy
  end

  def language_deliverable
    @lang_id = params[:language]
    @deliverable_id = params[:deliverable]
    # @this_month = TranslationProgress.where(language_id: @lang_id, deliverable_id: @deliverable_id, month: month).pluck :chapter_id
    # @other_month = TranslationProgress.where(language_id: @lang_id, deliverable_id: @deliverable_id).where.not(month: month).pluck :chapter_id
    respond_to :js
  end

end
