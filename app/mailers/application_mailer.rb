class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => app_email
  layout 'mailer'
end
