class BcsSms
  include HTTParty

  debug_output $stdout
  base_uri 'smsserver.bridgeconn.com'
  format :json
  default_params(
    secret_key: Rails.application.secrets.sms_api_key,
    secret_token: Rails.application.secrets.sms_api_token
  )

  def self.send_otp(phone_number, otp_code)
    post '/send_otp', body: {
        mobile_number: phone_number,
        otp: otp_code,
    }
  end

  def self.success? (response)
    response['status']
  end

end
