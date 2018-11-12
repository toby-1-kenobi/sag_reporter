class LanguageStreamsController < ApplicationController

  before_action :require_login

  def show
    @language_stream = LanguageStream.find(params[:id])
    if @language_stream.project.present?
      head :forbidden unless logged_in_user.can_view_project?(@language_stream.project)
    end
    @outputs = {}
    @language_stream.ministry.deliverables.facilitator.each do |deliverable|
      @outputs[deliverable.id] ||= {}
      deliverable.aggregate_ministry_outputs.where(state_language: @language_stream.state_language).where('month >= ?', 6.months.ago.strftime("%Y-%m")).each do |amo|
        @outputs[deliverable.id][amo.month] ||= {}
        @outputs[deliverable.id][amo.month][amo.actual] = [amo.id, amo.value, amo.comment]
      end
    end
    respond_to :js
  end

  def destroy
    language_stream = LanguageStream.find(params[:id])
    if language_stream
      if language_stream.project.present?
        head :forbidden unless logged_in_user.can_edit_project?(language_stream.project)
      end
      language_stream.destroy
    else
      Rails.logger.error("couldn't find LanguageStream ##{params[:id]} to delete")
    end
    @language_stream_id = params[:id]
    respond_to :js
  end

end
