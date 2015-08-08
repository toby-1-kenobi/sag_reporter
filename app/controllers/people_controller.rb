class PeopleController < ApplicationController

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:index] do
    redirect_to root_path unless current_user.can_view_all_people?
  end

  def index
  	@people = Person.order("LOWER(name)").paginate(page: params[:page])
  	@showing_all = true
  end

  def contacts
  	@people = Person.where(record_creator: current_user).order("LOWER(name)").paginate(page: params[:page])
  	@showing_all = false
  	render 'index'
  end

  def new
  	@person = Person.new
  end

  def create
  	full_person_params = person_params
  	full_person_params[:record_creator] = current_user
  	@person = Person.new(full_person_params)
  	if @person.save
  	  flash['success'] = "New contact created"
  	  redirect_to @person
  	else
  	  render 'new'
  	end
  end

  def show
  	@person = Person.find(params[:id])
  end

  private

  def person_params
  	params.require(:person).permit(
  		:name,
  		:phone,
  		:description,
  		:address,
  		:intern,
  		:facilitator,
  		:pastor,
  		:mother_tongue_id
  	)
  end

end
