class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => 'info@lci-india.org'
  layout 'mailer'
end
