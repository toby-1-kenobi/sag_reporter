require 'openssl'
require 'base64'

class BcsSms
  include HTTParty

  base_uri 'smsserver.bridgeconn.com'
  format :json

  # keep track of background process waiting for a response
  # use thread id as keys
  @requests_waiting = Hash.new

  # start a thread that sends the OTP and return the id of that thread
  def self.send_otp(phone_number, otp_code)
    if Rails.env.production?
      thr = Thread.new do
        @requests_waiting[Thread.current.object_id] = :pending
        begin
          response = post '/send_otp', body: {
              mobile_number: BcsSms.encrypt(phone_number),
              otp: BcsSms.encrypt(otp_code),
              secret_key: BcsSms.encrypt(Rails.application.secrets.sms_api_key),
              secret_token: BcsSms.encrypt(Rails.application.secrets.sms_api_token)
          }
          @requests_waiting[Thread.current.object_id] = response.parsed_response
        rescue => e
          @requests_waiting[Thread.current.object_id] = {'status' => 'error', 'message' => e.message}
        ensure
          ActiveRecord::Base.connection.close
        end
      end
      return thr.object_id
    else
      puts "Login code: #{otp_code}"
      return 0
    end
  end

  def self.poll(thread_id)
    if @requests_waiting[thread_id].present?
      if @requests_waiting[thread_id] == :pending
        return { 'status' => 'pending' }
      else
        return @requests_waiting.delete(thread_id)
      end
    else
      return { 'status' => 'invalid ticket' }
    end
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
