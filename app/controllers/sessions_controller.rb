class SessionsController < ApplicationController
  before_action :check_user, only: [:two_factor_auth, :new]

  def new
  end

  def two_factor_auth
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      @phone = params[:session][:phone]
      @password = params[:session][:password]
      otp_code = user.otp_code
      session[:temp_user] = user.id
      message = "OTP has been sent in your registered mobile number"
      if valid? "+91#{@phone}"
        send_otp_on_phone("+91#{@phone}", otp_code)
        if send_otp_via_mail(user, otp_code)
          message = message + " and your registered email address."
        end
        flash.now['info'] = message
      else
        flash.now['info'] = "Something went wrong. Please check phone number or Internet connection."
        render 'new'
      end
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
    phone_number = user.phone
    if user && valid?("+91#{phone_number}") == true
      send_otp_on_phone("+91#{phone_number}", user.otp_code)
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

  def send_otp_on_phone(phone_number, otp_code)
    TWILIO.messages.create(
      from: ENV['PHONE_NUMBER'],
      to: phone_number,
      body: 'Your LCI verification code is:'+otp_code.to_s
    )
  end

  def send_otp_via_mail(user, otp_code)
    if user.email && user.email_confirmed
      UserMailer.user_otp_code(user, otp_code).deliver
      return true
    else
      return false
    end
  end

  def valid?(phone_number)
    begin
      response = TWILIO_LOOKUP_CLIENT.phone_numbers.get(phone_number)
      response.phone_number #if invalid, throws an exception. If valid, no problems.
      return true
    rescue => e
      return false
    end
  end

  def check_user
     redirect_to root_path if logged_in?
  end
end
