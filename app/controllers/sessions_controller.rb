class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      log_in user
      remember user
      redirect_back_or user
    else
      flash.now["error"] = 'Phone number or password not correct'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end
end
