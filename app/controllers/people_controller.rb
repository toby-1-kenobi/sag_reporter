class PeopleController < ApplicationController

  def index
  	@people = Person.order("LOWER(name)").paginate(page: params[:page])
  	@showing_all = true
  end

  def contacts
  	@people = Person.where(record_creator: current_user).order("LOWER(name)").paginate(page: params[:page])
  	@showing_all = false
  	render 'index'
  end

end
