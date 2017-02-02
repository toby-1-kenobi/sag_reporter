class SessionsController < ApplicationController
  before_action :check_user, only: [:two_factor_auth, :new, :resend_otp_to_phone, :resend_otp_to_email]

  def new
  end

  def two_factor_auth
    @user = User.find_by(phone: params[:session][:phone])
    if @user && @user.authenticate(params[:session][:password])
      phone = params[:session][:phone]
      otp_code = @user.otp_code
      session[:temp_user] = @user.id
      if send_otp_on_phone("+91#{phone}", otp_code)
        flash.now['info'] = "A short login code has been sent to your phone (#{phone})"
      elsif send_otp_via_mail(@user, otp_code)
        flash.now['info'] = "A short login code has been sent to your email (#{@user.email})."
      else
        flash.now['error'] = "We were not able to send the login code to #{phone} or email #{@user.email}!"
      end
    else
      flash.now['error'] = 'Phone number or password is not correct'
      render 'new'
    end
  end

  def verify_otp
    user = User.find_by(id: session[:temp_user])
    if user && user.authenticate_otp(params[:otp_code], drift:60)
      render json: { success: true, message: 'Login code verified successfully.' }
    else
      render json: { success: false, message: 'Your login code expired or you did not enter it correctly. please click on \'resend code\' and try to login again.' }
    end
  end

  def resend_otp_to_phone
    logger.debug('resend otp')
    if session[:temp_user]
      user = User.find_by(id: session[:temp_user])
      if user and send_otp_on_phone("+91#{user.phone}", user.otp_code)
        #success
        render json: { success: true }
      else
        #fail
        render json: { success: false }
      end
    else
      # no temp user so we need the login credentials
      redirect_to login_path
    end
  end

  def resend_otp_to_email
    logger.debug('resend otp email')
    if session[:temp_user]
      user = User.find_by(id: session[:temp_user])
      if user and send_otp_via_mail(user, user.otp_code)
        #success
        render json: { success: true }
      else
        #fail
        render json: { success: false }
      end
    else
      # no temp user so we need the login credentials
      redirect_to login_path
    end
  end

  def create
    user = User.find_by(phone: params[:session][:phone])
    if user && session[:temp_user] == user.id && user.authenticate(params[:session][:password])
        session[:temp_user] = nil
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

  private

  def send_otp_on_phone(phone_number, otp_code)
    begin
      logger.debug("phone: #{phone_number}, otp: #{otp_code}")
      response = BcsSms.send_otp(phone_number, otp_code)
      logger.debug(response)
      return BcsSms.success?(response)
    rescue => e
      logger.error("couldn't send OTP to phone: #{e.message}")
      return false
    end
  end

  def send_otp_via_mail(user, otp_code)
    if user.email.present? && user.email_confirmed?
      UserMailer.user_otp_code(user, otp_code).deliver_now
      return true
    else
      return false
    end
  end

  def check_user
     redirect_to root_path if logged_in?
  end
end
