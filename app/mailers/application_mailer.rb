class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid
  default :from => ENV['REV79_VARIETY'].downcase == 'sandbox' ? 'info@example.com' : 'info@lci-india.org'
  layout 'mailer'
end
