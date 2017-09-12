class SessionsController < ApplicationController

  before_action :check_user, only: [:two_factor_auth, :new, :resend_otp_to_phone, :resend_otp_to_email]

  # methods related to an external client (=android app)
  skip_before_action :verify_authenticity_token, only: [:create_external, :show_external]

  before_action only: [:show_external] do
    begin
      full_params = params.require(:session).permit :user_id, :device_id
      @user = User.find_by_id(full_params['user_id']) if full_params['user_id'] != -1
      unless @user && @user.external_devices.map{|d| d.device_id if d.registered}.include?(full_params[:device_id])
        puts "Device not registered"
        head :not_found
      end
    rescue => e
      puts e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end
  
  # login
  def create_external
    begin
      auth_params = params.require(:auth).permit :phone, :password, :device_id, :device_name
      @user = User.find_by phone: auth_params[:phone]
      unless @user
        head :not_found
        return
      end
      if @user.authenticate auth_params[:password]
        users_device = @user.external_devices.find{|d| d.device_id == auth_params[:device_id]}
        if users_device && users_device.registered
          secret_key = Rails.application.secrets.secret_key_base
          payload = {sub: @user.id, iat: Time.now.to_i, iss: users_device.device_id}
          token = JWT.encode payload, secret_key, 'HS256'
          database_key = (@user.created_at.to_f * 1000000).to_i
          session_data = { jwt: token, user: @user.id , key: database_key}
          puts session_data
          render json: session_data, status: :created
        else
          unless users_device
            new_device = ExternalDevice.new
            new_device.device_id = auth_params[:device_id]
            new_device.name = auth_params[:device_name]
            new_device.user = @user
            new_device.registered = true #todo: replace this with a manual registration on users/edit
            new_device.save
            #remove those following lines, if manual registration is implemented
            secret_key = Rails.application.secrets.secret_key_base
            payload = {sub: @user.id, iat: Time.now.to_i, iss: new_device.device_id}
            token = JWT.encode payload, secret_key, 'HS256'
            database_key = (@user.created_at.to_f * 1000000).to_i
            session_data = { jwt: token, user: @user.id , key: database_key}
            puts session_data
            render json: session_data, status: :created
            return
          end
          puts "Device not registered"
          render json: { user: @user.id, error: "not_registered" }, status: :unauthorized
        end
      else
        puts "Wrong password"
        head :not_found
      end
    rescue => e
      puts e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  # send database decryption key
  def show_external
    begin
      database_key = (@user.created_at.to_f * 1000000).to_i
      puts database_key
      render json: { key: database_key }, status: :ok
    rescue => e
      puts e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end
  # until here methods were related to an external client (=android app)

  def new
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
