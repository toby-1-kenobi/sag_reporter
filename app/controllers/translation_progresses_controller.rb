class TranslationProgressesController < ApplicationController

  before_action :require_login

  def create
    if params[:translation_progress][:book_id]
      @translation_project_id = params[:translation_progress][:translation_project_id]
      @month = params[:translation_progress][:month] || 'none'
      @book = Book.find params[:translation_progress].delete(:book_id)
      @progressed = {}
      @book.chapter_ids.each do |ch_id|
        params[:translation_progress][:chapter_id] = ch_id
        tp = TranslationProgress.new(translation_progress_params)
        tp.save if tp.valid?
        @progressed[tp.chapter_id] = tp.id if tp.persisted?
      end
      count_verses(@translation_project_id, params[:translation_progress][:deliverable_id])
    else
      Rails.logger.debug translation_progress_params
      @translation_progress = TranslationProgress.create(translation_progress_params)
      count_verses(@translation_progress.translation_project_id, @translation_progress.deliverable_id)
    end
    respond_to :js
  end

  def destroy
    @translation_progress_id = params[:id]
    tp = TranslationProgress.find(@translation_progress_id)
    @translation_project = tp.translation_project
    deliverable_id = tp.deliverable_id
    tp.destroy
    count_verses(@translation_project.id, deliverable_id)
    respond_to :js
  end

  def unselect_book
    @book_id = params[:book]
    chapters = Chapter.where(book_id: @book_id).pluck :id
    @tp_ids = TranslationProgress.where(
        month: params[:month],
        translation_project_id: params[:translation_project],
        deliverable_id: params[:deliverable],
        chapter_id: chapters
    ).pluck :id
    Rails.logger.debug @tp_ids
    TranslationProgress.where(id: @tp_ids).destroy_all
    respond_to :js
  end

  def language_deliverable
    @translation_project = TranslationProject.find params[:translation_project]
    @deliverable_id = params[:deliverable]
    @lang_stream_id = params[:lang_stream]
    count_verses(@translation_project.id, @deliverable_id)
    respond_to :js
  end

  private

  def count_verses(translation_project_id, deliverable_id)
    @counts = {ot: {}, nt: {}}
    @counts.keys.each do |testament|
      @counts[testament] = {by_month: Hash.new(0)}
      verse_totals = Chapter.joins(:book).where(books: {nt: testament == :nt}).pluck(:id, :verses).to_h
      completed_chapters = TranslationProgress.joins(chapter: :book).where(translation_project_id: translation_project_id, deliverable_id: deliverable_id, books: {nt: testament == :nt}).pluck(:chapter_id, :month).to_h
      completed_chapters.each{ |chapter, month| @counts[testament][:by_month][month || 'none'] += verse_totals[chapter] }
      @counts[testament][:total_verses] = verse_totals.select{ |chapter, _| completed_chapters.keys.include? chapter }.reduce(0){ |sum, vt| sum + vt[1] }
      @counts[testament][:remaining_verses] = verse_totals.select{ |chapter, _| completed_chapters.keys.exclude? chapter }.reduce(0){ |sum, vt| sum + vt[1] }
    end
  end

  def translation_progress_params
    params['translation_progress']['month'] = nil if params['translation_progress'] && params['translation_progress']['month'] == 'none'
    Rails.logger.debug(params)
    params.require(:translation_progress).permit([
                                                     :deliverable_id,
                                                     :translation_project_id,
                                                     :chapter_id,
                                                     :month,
                                                     :translation_method,
                                                     :translation_tool
                                                 ])
  end

end
