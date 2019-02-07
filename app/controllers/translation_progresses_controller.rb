class TranslationProgressesController < ApplicationController

  before_action :require_login

  def create
    @translation_progress = TranslationProgress.create(translation_progress_params)
    respond_to :js
  end

  def destroy
    @translation_progress_id = params[:id]
    TranslationProgress.find(@translation_progress_id).destroy
    respond_to :js
  end

  def language_deliverable
    @lang_id = params[:language]
    @deliverable_id = params[:deliverable]
    @lang_stream_id = params[:lang_stream]
    # @this_month = TranslationProgress.where(language_id: @lang_id, deliverable_id: @deliverable_id, month: month).pluck :chapter_id
    # @other_month = TranslationProgress.where(language_id: @lang_id, deliverable_id: @deliverable_id).where.not(month: month).pluck :chapter_id
    respond_to :js
  end

  private

  def translation_progress_params
    params.require(:translation_progress).permit([
                                                     :deliverable_id,
                                                     :language_id,
                                                     :chapter_id,
                                                     :month,
                                                     :translation_method,
                                                     :translation_tool
                                                 ])
  end

end
