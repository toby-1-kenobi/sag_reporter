class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  include UsersHelper

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.update_attribute(:reset_password, true)
      flash[:info] = "Your request submitted admin will reach you shortly"
      render 'new'
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def approve_user_request
    @user = User.find_by(id: params[:id])
    if @user and @user.update_attributes(reset_password: false, reset_password_token: SecureRandom.urlsafe_base64(nil, false))
      @mail_sent = send_pwd_reset_instructions(@user)
    else
      Rails.logger.error ("failed to update attributes in user ##{params[:id]} for password reset approval")
    end
    respond_to :js
  end

  def reject_user_request
      @user = User.find_by(id: params[:id])
      if @user
        @user.update_attribute(:reset_password, false)
      end
      respond_to :js
  end

  def verify
     render 'password_resets/verify_otp'
  end

  def verify_otp
      user = User.find_by(email: params[:verify_otp][:email])
      user_otp = params[:verify_otp][:otp]
      if user and user.authenticate_otp(user_otp, drift: 300)
        session[:temp_user] = user.id
        render 'password_resets/change_password'
      else
        @user = user
        flash.now['error'] = 'Login code incorrect or expired.'
      end

  end

  def password_change
      if logged_in_user.update_attributes(
                           password: params[:change_password][:password],
                           password_confirmation: params[:change_password][:password_confirmation]
      )
        flash[:success] = 'Your password successfully updated'
        redirect_to root_path
      else
        flash.now[:error] = 'Your password update failed'
        render 'password_resets/change_password'
      end
  end

  private

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
        @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end



end