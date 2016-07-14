class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      log_in user
      remember user
      if params[:session][:password] == 'password'
        flash['info'] = 'Welcome to Last Command Initiative Reporter.' +
            ' Please make a new password. It should be something another person could not guess.' +
            ' Type it here two times and click \'update\'.'
        redirect_to edit_user_path(user)
      else
        redirect_back_or root_path
      end
    else
      flash.now['error'] = 'Phone number or password not correct'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end
end
