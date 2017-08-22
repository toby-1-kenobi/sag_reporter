class UserMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => 'info@lci.com'
  def user_email_confirmation(user)
  	headers['X-SMTPAPI'] = {
      category: ['lciemailconfirm']
    }.to_json
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => 'Email Confirmation')
  end

  def user_otp_code(user, otp_code)
    headers['X-SMTPAPI'] = {
      category: ['lcilogincode']
    }.to_json
    @otp_code = otp_code
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => 'OTP login code')
  end

  def user_report(recipient, report)
    headers['X-SMTPAPI'] = {
        category: ['lcireport']
    }.to_json
    @report = report
    if recipient.class == User
      @recipient = recipient
      mail(:to => "#{recipient.name} <#{recipient.email}>", :subject => 'New LCI report')
    else
      mail(:to => recipient, :subject => 'New LCI report')
    end
  end

end
