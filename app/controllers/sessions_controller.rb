class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
    else
      flash["error"] = 'Phone number or password not correct' # Not quite right!
      render 'new'
    end
  end

  def destroy
  end
end
