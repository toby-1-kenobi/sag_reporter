require 'sendgrid-ruby'
SEND_GRID = SendGrid::Client.new do |c|
  c.api_key = ENV['SENDGRID_API_KEY']
end