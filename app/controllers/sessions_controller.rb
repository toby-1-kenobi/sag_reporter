class SessionsController < ApplicationController
  def new
  end

  def two_factor_auth
    user = User.find_by(phone: params[:session][:phone])
    if user && user.authenticate(params[:session][:password])
      @phone = params[:session][:phone]
      @password = params[:session][:password]
      @otp_code = user.otp_code
      session[:temp_user] = user.id
      # TWILIO.messages.create(
      #   from: '+15856450851',
      #   to: "+91"+@phone.to_s,
      #   body: 'Your LCI verification code is:'+@otp_code
      # )
      flash.now['info'] = "OTP has been sent in your registered mobile number"
    else
      flash.now['error'] = 'Phone number or password not correct'
      render 'new'
    end
  end

  def verify_otp
    user = User.find_by(id: session[:temp_user])
    if user && user.authenticate_otp(params[:otp_code])
      render json: { success: true }
    else
      render json: { success: false, message: "OTP has expired please click on resend otp and try to login again" }
    end
  end

  def resend_otp
    user = User.find_by(id: session[:temp_user]) if session[:temp_user]
    code = user.otp_code
    if code
      render json: { success: true, message: "OTP sent successfully.", otp_code: code }
    else
      render json: { success: false, message: "Oops. Something went wrong. Please try later." }
    end
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
