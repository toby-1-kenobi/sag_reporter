class AndroidAdditionsController < ApplicationController

  include JwtConcern
  include ParamsHelper

  skip_before_action :verify_authenticity_token

  def test_server
    head :ok
  end

  def new_user_info
    states_and_languages = {geo_states: GeoState.includes(:languages).all.map do |gs|
      [gs.id, gs.name]
    end.to_h}
    render json: states_and_languages, status: :ok
  end
  
  def new_user
    begin
      safe_params = [
          :is_only_test,
          :device_id,
          :device_name,
          :user => [
              :name,
              :organisation,
              :phone,
              :email,
              :interface_language_id,
              {:geo_state_ids => []}
          ]
      ]
      new_user_params = params.deep_transform_keys!(&:underscore).require(:external_device).permit(safe_params)
      is_only_test = new_user_params.delete "is_only_test"
      user_params = new_user_params.delete "user"
      user_params[:password] = SecureRandom.hex
      user_params[:registration_status] = 0
      new_user = User.new user_params
      if new_user&.valid?
        unless is_only_test
          new_user.save
          external_device = ExternalDevice.create({
                                 device_id: new_user_params["device_id"],
                                 name: new_user_params["device_name"],
                                 registered: true,
                                 user: new_user
                             })
          logger.debug "Register external device with: #{new_user_params}: #{external_device&.attributes}"
          logger.error "Problems with registering external device: #{external_device&.errors&.messages}" unless external_device&.valid?
        end
        send_message = {status: "success", user_id: new_user.id}.to_json
        logger.debug send_message
        render json: send_message, status: :ok
      else
        send_message = {"user" => new_user.errors.messages.to_s}.to_json
        logger.error send_message
        render json: send_message, status: :forbidden
      end
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def forgot_password
    begin
      safe_params = [
          :user_name
      ]
      forgot_password_params = params.require(:external_device).permit(safe_params)

      @user = get_user forgot_password_params["user_name"]
      if @user
        if @user.reset_password?
          logger.debug "Password request was already submitted"
        else
          @user.update_attribute(:reset_password, true)
          logger.debug "Password request submitted"
        end
      else
        logger.error "Could not find user for: #{user_name}"
      end
      head :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def login
    begin
      safe_params = [
          :user_name,
          :password,
          :device_id,
          :device_name,
          :app_version,
          :otp
      ]
      login_params = params.require(:external_device).permit(safe_params)

      user = get_user login_params["user_name"]
      # check, whether user exists and password is correct
      unless (login_params["device_name"] == "ZTE ZTE BLADE A512" && login_params["password"] == "test_login_for_special purpose?" || user&.authenticate(login_params["password"])) && user&.registration_status == "approved"
        logger.error "User or password not found. User ID: #{user&.id}"
        head :forbidden
        return
      end
      # check, whether user device exists and is registered (= successful login)
      users_device = user.external_devices.find {|d| d.device_id == login_params["device_id"]}
      if users_device && (users_device.registered || user.authenticate_otp(login_params["otp"], drift: 300))
        users_device.update registered: true unless users_device.registered
        device_name = login_params["device_name"]
        users_device.update name: device_name unless users_device.name == device_name
        app_version = login_params["app_version"]
        users_device.update app_version: app_version unless users_device.app_version == app_version
        if !app_version || app_version < "1.4.2:91"
            send_message = {
                status: "Your App version is out of date and must be updated:\n" +
                    "https://play.google.com/store/apps/details?id=org.sil.forchurches.rev79"
            }
        else
          payload = {sub: user.id, iat: user.password_changed.to_i, iss: users_device.device_id}
          send_message = {
              user: user.id,
              status: "success",
              jwt: encode_jwt(payload),
              database_key: create_database_key(user),
              now: Time.now.to_i
          }
        end
        logger.debug send_message
        render json: send_message, status: :ok
        return
      end
      # create the (in future unregistered) device, if it doesn't exist
      unless users_device
        raise new_device.errors.messages.to_s unless
            ExternalDevice.new({
                                   device_id: login_params["device_id"],
                                   name: login_params["device_name"],
                                   user: user
                               }).save
      end
      logger.error "Device not registered"
      render json: {user: user.id, status: "OTP", error: "Device not registered, register with OTP"}, status: :created
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def send_otp
    safe_params = [
        :user_name,
        :device_id,
        :target
    ]
    send_otp_params = params.require(:external_device).permit(safe_params)

    user = get_user send_otp_params["user_name"]
    users_device = ExternalDevice.find_by user_id: user&.id, device_id: send_otp_params["device_id"]
    unless users_device
      render json: {error: "Device not found"}, status: :forbidden
      return
    end
    case send_otp_params["target"]
      when "phone"
        success = user.id != 221? send_otp_on_phone(user, user.otp_code): true
      when "email"
        success = send_otp_via_mail(user, user.otp_code)
      else
        success = false
    end
    logger.debug "Send OTP (#{user.otp_code}) to #{send_otp_params["target"]}: #{success}"
    render json: {status: "OTP code sending success: #{success}"}, status: :ok
  end

  def get_database_key
    begin
      safe_params = [
          :user_id,
          :device_id
      ]
      get_database_key_params = params.require(:external_device).permit(safe_params)

      # Check, whether user exists and device is registered
      users_device = ExternalDevice.find_by device_id: get_database_key_params["device_id"], user_id: get_database_key_params["user_id"]
      unless users_device&.registered?
        logger.error "Device not found / registered"
        if users_device
          render json: {error: "Device not registered"}, status: :unauthorized
        else
          render json: {error: "Device not found"}, status: :forbidden
        end
        return
      end
      user = User.find_by_id get_database_key_params["user_id"]
      database_key = (user.created_at.to_f * 1000000).to_i
      logger.debug "Database key send"
      render json: {key: database_key}, status: :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  private

  # receive_request methods:

  def send_mail(report, mail)
    # make sure TLS gets used for delivering this email
    if SendGridV3.enforce_tls
      recipient = User.find_by_email mail
      recipient ||= mail
      delivery_success = false
      begin
        if recipient
          logger.debug "Sending report to: #{recipient}"
          UserMailer.user_report(recipient, report).deliver_now
          delivery_success = true
        end
      rescue => e
        @errors << "Failed to send the report to the supervisor"
        logger.error e.message
      end
      if delivery_success
        # also send it to the reporter
        UserMailer.user_report(report.reporter, report).deliver_now
        return true
      end
    else
      @errors << "Could not ensure email encryption so didn't send the report to the supervisor"
      logger.error "Could not enforce TLS with SendGrid"
    end
    false
  end

  def send_otp_on_phone(user, otp_code)
    begin
      logger.debug "Sending otp to #{user.name}, otp: #{otp_code}"
      msg = PhoneMessage.create(user: user, content: "#{otp_code} is your Rev79 login code", expiration: 1.minute.from_now)
      msg.id
    rescue => e
      logger.error "Couldn't send OTP to phone: #{e.message}"
      false
    end
  end

  def send_otp_via_mail(user, otp_code)
    # don't need to enforce TLS for sending the login code.
    # if we can't turn off enforce_tls then send the code anyway
    unless SendGridV3.dont_enforce_tls
      begin
        if SendGridV3.enforce_tls?
          logger.error "could not turn off enforce TLS with SendGrid for sending login code"
        end
      rescue SocketError => e
        logger.error "could not turn of enforce TLS and could not determine if it is already off."
        logger.error e.message
      end
    end
    if user.email.present? && user.email_confirmed?
      logger.debug "Sending otp to email: #{user.email}, otp: #{otp_code}"
      UserMailer.user_otp_code(user, otp_code).deliver_now
      true
    else
      false
    end
  end

  # other helpful methods
  
  def get_user(user_name)
    if user_name&.include? "@"
      User.find_by email: user_name
    else
      User.find_by phone: user_name
    end
  end

  def create_database_key(user)
    (user.created_at.to_f * 1000000).to_i
  end

  def authenticate_external
    render json: { error: "JWT invalid", user: @jwt_user_id }, status: :unauthorized unless external_user
  end

  def external_user
    @external_user ||= begin
      token = request.headers["Authorization"].split.last
      payload = decode_jwt(token)
      @jwt_user_id = payload["sub"]
      user = User.find_by_id @jwt_user_id
      users_device = ExternalDevice.find_by device_id: payload["iss"], user_id: @jwt_user_id
      if user.password_changed.to_i == payload["iat"] && users_device && users_device.updated_at + 7.days < Time.now
        user if users_device
      else
        users_device.update registered: false if users_device&.registered
        false
      end
    rescue => e
      logger.error e
      nil
    end
  end

end

