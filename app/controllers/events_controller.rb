class EventsController < ApplicationController

  autocomplete :person, :name
  
  def new
  	@event = Event.new()
  	@minority_languages = Language.where(lwc: false)
  end
end
