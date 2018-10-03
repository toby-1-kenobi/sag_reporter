class PhoneMessagesController < ApplicationController

  skip_before_action :verify_authenticity_token

  def pending
    respond_to do |format|
      format.json { render json: PhoneMessage.pending }
    end
  end

  def update
    # sent param should contain a list of phone message ids that got sent
    params[:sent].each do |id|
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

    # errors param contains a hash with message id as key and error messages as values
    params[:errors].each do |id, error_messages|
      sms = PhoneMessage.find id
      if sms
        sms.error_messages = error_messages
        sms.save
      else
        Rails.logger.warning "SMS server sent invalid message id #{id}"
      end
    end

    respond_to do |format|
      format.json { render json: 'OK' }
    end
  end

end
