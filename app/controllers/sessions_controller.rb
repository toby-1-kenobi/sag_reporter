require 'messagebird'


class SessionsController < ApplicationController

  before_action :check_user, only: [:two_factor_auth, :new, :resend_otp_to_phone, :resend_otp_to_email]

  before_action only: [:change] do
    redirect_to root_path unless logged_in_user.admin?
  end

  def new
  end

  def two_factor_auth

    # check if we are getting a user who is resetting their password
    # if so, the passed parameters will include :id and :token
    if params[:user_id] and params[:token]
      @user = User.find params[:user_id]
      redirect_to login_path unless @user
      if BCrypt::Password.new(@user.reset_password_token).is_password?(params[:token])
        session[:temp_user] = @user.id
        # for this user we can skip the otp process
        log_in @user
        remember @user
        @user.reset_password_token = nil
        @user.save
        render 'password_resets/change_password' and return
      else
        flash['error'] = 'Incorrect reset password token'
        redirect_to login_path
      end

    # otherwise we need to find the user and authenticate them by username and password
    else
      username = params[:session][:username]
      if username.include? '@'
        # if the user has put something with an '@' in it is must be their email address
        @user = User.find_by(email: username)
      else
        # otherwise we'll assume it's their phone number
        @user = User.find_by(phone: username)
      end
      # skip authentication for the development environment and sandbox
      if @user and (Rails.env.development? or ENV['REV79_VARIETY'].downcase == 'sandbox')
        log_in @user
        remember @user
        redirect_back_or root_path and return
      end
      if @user && @user.authenticate(params[:session][:password])
        if @user.registration_status == 'approved'
          logger.debug 'authenticated, sending OTP'
          session[:temp_user] = @user.id
          send_otp(@user)
        elsif @user.disabled?
          logger.debug "User account disabled"
          flash.now['error'] = 'Your account has been disabled. Please contact your supervisor if it should be reenabled'
          render 'new'
        else
          logger.debug "User account pending approval"
          flash.now['error'] = 'Your account is still waiting for registration approval.'
          render 'new'
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
  end

  def resend_otp_to_phone
    logger.debug('resend otp')
    if session[:temp_user]
      if user = User.find_by(id: session[:temp_user])
        @ticket = send_otp_on_phone(user, user.otp_code)
        respond_to :js
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
      if user = User.find_by(id: session[:temp_user])
        if send_otp_via_mail(user, user.otp_code)
          @success = true
        else
          @success = false
        end
      else
        @success = false
      end
      respond_to :js
    else
      # no temp user so we need the login credentials
      redirect_to login_path
    end
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

    if user and user.authenticate_otp(params[:session][:otp_code].strip, drift: 300)
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

  # allow admin users to "become" any other user
  def change
    user = User.find params[:id]
    log_in user
    flash['success'] = "Switched account to #{user.name}"
    redirect_to root_path
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end

  def sign_up
    @user = User.new
    @geo_states = GeoState.all.order(:name)
  end

  private

  def send_otp(user)
    otp_code = user.otp_code
    if user.phone.present? and not user.email_confirmed?
      @ticket = send_otp_on_phone(user, otp_code)
      flash.now['info'] = "A short login code has been sent to your phone (#{user.phone}). Please wait for it."
    elsif user.phone.blank? and send_otp_via_mail(@user, otp_code)
      flash.now['info'] = "A short login code has been sent to your email (#{user.email}). Check your inbox."
    elsif user.phone.present? and user.email.present? and user.email_confirmed?
      flash.now['info'] = "Please choose to have the login code sent to your phone (#{user.phone}) or email (#{user.email})"
    end
  end

  def send_otp_on_phone(user, otp_code)
    begin
      logger.debug("sending otp to: #{user.name}, otp: #{otp_code}")
      client = MessageBird::Client.new(ENV['SMS_API_KEY'])
      response = client.message_create(
          'Rev79',
          #TODO: Country code is hardcoded
          ["+91#{user.phone}"],
          "#{otp_code} is your Rev79 login code."
      )
      return response.recipients['totalSentCount'] >= 1
      # msg = PhoneMessage.create(user: user, content: "#{otp_code} is your Rev79 login code", expiration: 1.minute.from_now)
      # logger.debug("waiting #{msg.id}")
      #return msg.id
    rescue => e
      logger.error("couldn't send OTP to phone: #{e.message}")
      return false
    end
  end

  def send_otp_via_mail(user, otp_code)
    # don't need to enforce TLS for sending the login code.
    # if we can't turn off enforce_tls then send the code anyway
    unless SendGridV3.dont_enforce_tls
      begin
        if SendGridV3.enforce_tls?
            Rails.logger.error 'could not turn off enforce TLS with SendGrid for sending login code'
        end
      rescue SocketError => e
        Rails.logger.error 'could not turn of enforce TLS and could not determine if it is already off.'
        Rails.logger.error e.message
      end
    end
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
