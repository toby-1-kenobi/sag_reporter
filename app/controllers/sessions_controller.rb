class SessionsController < ApplicationController

  before_action :check_user, only: [:two_factor_auth, :new, :resend_otp_to_phone, :resend_otp_to_email]
  skip_before_action :verify_authenticity_token, only: [:create_external]

  def new
  end

  def create_external
    auth_params = params.require(:auth).permit :phone, :password
    user = User.find_by phone: auth_params[:phone]
    if !user
      head :not_found
      return
    end
    secret_key = Rails.application.secrets.secret_key_base
    payload = {sub: user.id, iat: Time.now.to_i}
    token = JWT.encode payload, secret_key, 'HS256'
    if user.authenticate auth_params[:password]
      render json: { jwt: token, user: user.id }, status: :created
    else
      head :not_found
    end
  end

  def two_factor_auth
    username = params[:session][:username]
    if username.include? '@'
      # if the user has put something with an '@' in it is must be their email address
      @user = User.find_by(email: username)
    else
      # otherwise we'll assume it's their phone number
      @user = User.find_by(phone: username)
    end
    if @user && @user.authenticate(params[:session][:password])
      otp_code = @user.otp_code
      session[:temp_user] = @user.id
      if @user.phone.present? and not @user.email_confirmed?
        @ticket =  send_otp_on_phone("+91#{@user.phone}", otp_code)
        flash.now['info'] = "A short login code has been sent to your phone (#{@user.phone}). Please wait for it."
      elsif @user.phone.blank? and send_otp_via_mail(@user, otp_code)
        flash.now['info'] = "A short login code has been sent to your email (#{@user.email}). Check your inbox."
      elsif @user.phone.present? and @user.email.present? and @user.email_confirmed?
        flash.now['info'] = "Please choose to have the login code sent to your phone (#{@user.phone}) or email (#{@user.email})"
      end
    else
      if @user
        logger.debug "could not authenticate #{@user.phone} with '#{params[:session][:password]}'"
      else
        logger.debug "couldn't find user with  #{username}"
      end
      flash.now['error'] = 'username or password is not correct'
      render 'new'
    end
  end

  def resend_otp_to_phone
    logger.debug('resend otp')
    if session[:temp_user]
      if user = User.find_by(id: session[:temp_user])
        render json: { ticket: send_otp_on_phone("+91#{user.phone}", user.otp_code) }
      else
        # temp user doesn't exist so go back to square 1
        redirect_to login_path
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

  def poll
    ticket = params[:ticket]
    logger.debug("polling for #{ticket}")
    render json: BcsSms.poll(ticket.to_i)
  end

  def create
    # don't need to create a session if we're already logged in
    if logged_in?
      logger.debug 'already logged in!'
      redirect_to root_path and return
    end
    # if user password hasn't been authenticated yet then go back to login
    if session[:temp_user].blank?
      logger.debug 'user password not yet authenticated'
      redirect_to login_path and return
    end
    user = User.find session[:temp_user]

    if user and user.authenticate_otp(params[:session][:otp_code], drift: 300)
        session[:temp_user] = nil
        log_in user
        remember user
        # if the user's password is "password" they should change it
        if user.authenticate('password')
          flash['info'] = 'Welcome to Last Command Initiative Reporter.' +
              ' Please make a new password. It should be something another person could not guess.' +
              ' Type it here two times and click \'update\'.'
          redirect_to edit_user_path(user)
        else
          redirect_back_or root_path and return
        end
    else
      @user = user
      flash.now['error'] = 'Login code incorrect or expired.'
      render 'two_factor_auth'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end

  private

  def send_otp_on_phone(phone_number, otp_code)
    begin
      logger.debug("sending otp to phone: #{phone_number}, otp: #{otp_code}")
      wait_ticket = BcsSms.send_otp(phone_number, otp_code)
      logger.debug("waiting #{wait_ticket}")
      return wait_ticket
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
