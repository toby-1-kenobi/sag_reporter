class LanguageStreamsController < ApplicationController
  def destroy
    language_stream = LanguageStream.find(params[:id])
    if language_stream
      language_stream.destroy
    else
      Rails.logger.error("couldn't find LanguageStream ##{params[:id]} to delete")
    end
    @language_stream_id = params[:id]
    respond_to :js
  end
end
