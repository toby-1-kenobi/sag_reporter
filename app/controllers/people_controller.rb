class PeopleController < ApplicationController

  def index
  	@people = Person.order("LOWER(name)").paginate(page: params[:page])
  end

end
