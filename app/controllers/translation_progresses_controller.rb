class TranslationProgressesController < ApplicationController

  before_action :require_login

  def create
    @translation_progress = TranslationProgress.create(translation_progress_params)
    count_verses(@translation_progress.language_id, @translation_progress.deliverable_id)
    respond_to :js
  end

  def destroy
    @translation_progress_id = params[:id]
    tp = TranslationProgress.find(@translation_progress_id)
    @lang_id = tp.language_id
    deliverable_id = tp.deliverable_id
    tp.destroy
    count_verses(@lang_id, deliverable_id)
    respond_to :js
  end

  def language_deliverable
    @lang_id = params[:language]
    @deliverable_id = params[:deliverable]
    @lang_stream_id = params[:lang_stream]
    count_verses(@lang_id, @deliverable_id)
    respond_to :js
  end

  private

  def count_verses(language_id, deliverable_id)
    @counts = {ot: {}, nt: {}}
    @counts.keys.each do |testament|
      @counts[testament] = {by_month: Hash.new(0)}
      verse_totals = Chapter.joins(:book).where(books: {nt: testament == :nt}).pluck(:id, :verses).to_h
      completed_chapters = TranslationProgress.joins(chapter: :book).where(language_id: language_id, deliverable_id: deliverable_id, books: {nt: testament == :nt}).pluck(:chapter_id, :month).to_h
      completed_chapters.each{ |chapter, month| @counts[testament][:by_month][month || 'none'] += verse_totals[chapter] }
      @counts[testament][:total_verses] = verse_totals.select{ |chapter, _| completed_chapters.keys.include? chapter }.reduce(0){ |sum, vt| sum + vt[1] }
      @counts[testament][:remaining_verses] = verse_totals.select{ |chapter, _| completed_chapters.keys.exclude? chapter }.reduce(0){ |sum, vt| sum + vt[1] }
    end
  end

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
