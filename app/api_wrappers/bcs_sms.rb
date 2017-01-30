require 'openssl'
require 'base64'

class BcsSms
  include HTTParty

  # debug_output $stdout
  base_uri 'smsserver.bridgeconn.com'
  format :json

  def self.send_otp(phone_number, otp_code)
    post '/send_otp', body: {
        mobile_number: BcsSms.encrypt(phone_number),
        opt: BcsSms.encrypt(otp_code),
        secret_key: BcsSms.encrypt(Rails.application.secrets.sms_api_key),
        secret_token: BcsSms.encrypt(Rails.application.secrets.sms_api_token)
    }
  end

  def self.success? (response)
    response['status']
  end

  def self.encrypt(data)
    cipher = OpenSSL::Cipher.new(Rails.application.secrets.bcs_encrypt_algorithm)
    cipher.encrypt()
    cipher.key = Rails.application.secrets.bcs_encrypt_key
    crypt = cipher.update(data) + cipher.final
    crypt_string = (Base64.encode64(crypt))
    return crypt_string
  end

end
