Twilio.configure do |config|
  config.account_sid = ENV['ACCOUNT_SID']
  config.auth_token = ENV['AUTH_TOKEN']
end
TWILIO = Twilio::REST::Client.new
TWILIO_LOOKUP_CLIENT = Twilio::REST::LookupsClient.new