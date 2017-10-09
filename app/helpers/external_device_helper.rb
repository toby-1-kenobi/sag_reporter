module ExternalDeviceHelper

  def create_jwt user, device_id
    secret_key = Rails.application.secrets.secret_key_base
    payload = {sub: user.id, iat: Time.now.to_i, iss: device_id}
    token = JWT.encode payload, secret_key, 'HS256'
  end

  def create_database_key user
    database_key = (user.created_at.to_f * 1000000).to_i
  end

  def authenticate_external
    render json: { error: "JWT invalid" }, status: :unauthorized unless external_user
  end

  def external_user
    @external_user ||= begin
      token = request.headers['Authorization'].split.last
      secret_key = Rails.application.secrets.secret_key_base
      payload, _ = JWT.decode token, secret_key, true, {algorithm: 'HS256'}
      user = User.find_by_id payload['sub']
      device_is_registered = user.external_devices.map{|d| d.device_id if d.registered}.include?(payload['iss'])
      user if user.updated_at.to_i < payload['iat'] && device_is_registered
    rescue => e
      puts e
      nil
    end
  end
end
