require 'open-uri'

class UserMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => 'info@lci-india.org'
  def user_email_confirmation(user)
  	headers['X-SMTPAPI'] = {
      category: ['lciemailconfirm']
    }.to_json
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: 'Email Confirmation')
  end

  def user_otp_code(user, otp_code)
    headers['X-SMTPAPI'] = {
      category: ['lcilogincode']
    }.to_json
    @otp_code = otp_code
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: 'OTP login code')
  end

  def user_report(recipient, report)
    headers['X-SMTPAPI'] = {
      category: ['lcireport']
    }.to_json
    @report = report
    if recipient.class == User
      @recipient = recipient
      to_address = "#{recipient.name} <#{recipient.email}>"
      if recipient.trusted? and @report.pictures.any?
        @report.pictures.each do |pic|
          if Rails.env.production?
            # attach the image from a url
            attachments.inline[pic.ref_identifier] = open(pic.ref_url).read
          else
            # attach the image from local disk
            attachments.inline[pic.ref_identifier] = File.read(Rails.root.join "public#{pic.ref_url}")
          end
        end
      end
    else
      to_address = recipient
      # without more information treat the name of the recipient as the first part of the email address.
      @recipient_name = recipient.split('@').first
      Rails.logger.debug "recipient: #{recipient}, recipient_name: #{@recipient_name}"
    end
    mail(to: to_address, subject: 'New LCI report')
  end

end
