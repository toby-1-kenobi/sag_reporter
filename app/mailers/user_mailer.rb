class UserMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => "info@lci.com"

  def user_email_confirmation(user)
  	headers['X-SMTPAPI'] = {
      category: ['emailconfirm']
    }.to_json
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Email Confirmation")
  end
end
