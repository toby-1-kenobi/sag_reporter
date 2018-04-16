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
    email = @user.email
    if @user.update_attribute(:reset_password, false)
      send_otp_via_email(email)
      respond_to do |format|
        format.js
      end
    end

  end

  def reject_user_request
      @user = User.find_by(id: params[:id])
      if @user.update_attribute(:reset_password, false)
        respond_to do |format|
          format.js
        end
      end

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

      @user = User.find_by(id: session[:temp_user])
      user_password = User.find_by(password_digest: params[:change_password][:password])
      new_hashed_password = User.digest(user_password)

      if @user
        @user.update_attribute(:password_digest, new_hashed_password)
        flash[:info] = "Your password successfully updated"
        redirect_to login_url
      else
        flash.now[:danger] = "Your password update failed"
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