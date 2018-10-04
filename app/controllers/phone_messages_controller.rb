require 'openssl'
class PhoneMessagesController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_action except: [:poll] do
    head :forbidden unless recent_timestamp
  end

  before_action except: [:poll] do
    head :forbidden unless hmac_authorise
  end


  def pending
    respond_to do |format|
      format.json { render json: PhoneMessage.pending.to_json(only: [:id, :content], include: [user: { only: :phone }]) }
    end
  end

  def update
    # sent param should contain a list of phone message ids that got sent
    if params[:sent]
      JSON.parse(params[:sent]).each do |id|
        sms = PhoneMessage.find id
        if sms
          if sms.sent_at
            Rails.logger.error "Phone message #{id} already sent."
          else
            sms.sent_at = Time.now
            sms.save
          end
        else
          Rails.logger.warning "SMS server sent invalid message id #{id}"
        end
      end
    end

    # errors param contains a hash with message id as key and error messages as values
    if params[:errors]
      JSON.parse(params[:errors]).each do |id, error_messages|
        sms = PhoneMessage.find id
        if sms
          sms.error_messages = error_messages
          sms.save
        else
          Rails.logger.warning "SMS server sent invalid message id #{id}"
        end
      end
    end

    respond_to do |format|
      format.json { render json: 'OK' }
    end
  end

  def poll
    msg = PhoneMessage.find params[:id]
    if msg
      if msg.sent_at.present?
        response = { 'status' => true }
      elsif msg.error_messages.present?
        response = { 'status' => msg.error_messages }
      else
        response = { 'status' => 'pending' }
      end
    else
      response = { 'status' => 'invalid ticket' }
    end
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  def hmac_authorise
    client_token = request.headers['Authorization']
    timestamp = params['timestamp']
    Rails.logger.debug("timestamp => #{timestamp}")
    key = Rails.application.secrets.sms_key
    hmac_digest = OpenSSL::HMAC.hexdigest('sha1', key, timestamp)
    Rails.logger.debug hmac_digest
    Rails.logger.info("Bad hmac for phone message api") if hmac_digest != client_token
    hmac_digest == client_token
  end

  def recent_timestamp
    return false unless params['timestamp']
    # the timestamp in the request must be not less than 5 seconds ago
    delta = Time.now.to_i - params['timestamp'].to_i
    Rails.logger.info("Phone message api delta #{delta}") if delta > 5
    return delta <= 5
  end

end
