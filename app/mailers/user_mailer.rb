class UserMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid

  default :from => "me@mydomain.com"

  def user_email_confirmation(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Email Confirmation")
  end
end
