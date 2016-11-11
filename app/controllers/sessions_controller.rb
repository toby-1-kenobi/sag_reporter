class SessionsController < ApplicationController
  before_action :check_user, only: [:two_factor_auth, :new]

  def new
  end

  def two_factor_auth
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      @phone = params[:session][:phone]
      @password = params[:session][:password]
      @otp_code = user.otp_code
      session[:temp_user] = user.id
      send_otp(user)
      flash.now['info'] = "OTP has been sent in your registered mobile number"
    else
      flash.now['error'] = 'Phone number or password not correct'
      render 'new'
    end
  end

  def verify_otp
    user = User.find_by(id: session[:temp_user])
    if user && user.authenticate_otp(params[:otp_code], drift:60)
      render json: { success: true, message: "OTP sent successfully." }
    else
      render json: { success: false, message: "OTP has expired or you have entered wrong OTP. please click on resend OTP and try to login again." }
    end
  end

  def resend_otp
    user = User.find_by(id: session[:temp_user]) if session[:temp_user]
    if user
      send_otp(user)
      render json: { success: true, message: "OTP sent successfully." }
    else
      render json: { success: false, message: "Oops. Something went wrong. Please try later." }
    end
  end

  def create
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
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

  def send_otp(user)
    TWILIO.messages.create(
      from: ENV['PHONE_NUMBER'],
      to: "+91"+user.phone.to_s,
      body: 'Your LCI verification code is:'+user.otp_code.to_s
    )
  end

  def check_user
     redirect_to root_path if logged_in?
  end
end
