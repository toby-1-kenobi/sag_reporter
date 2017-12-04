SendGridActionMailerAdapter.configure do |config|
  config.api_key = ENV['SENDGRID_API_KEY']
  config.version = 'v3'
end
