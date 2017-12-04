class SendGridV3
  include HTTParty
  debug_output $stdout

  base_uri 'https://api.sendgrid.com/v3'
  format :json

  headers 'Authorization' => "Bearer #{ENV['SENDGRID_API_KEY']}"
  headers 'Content-Type' => 'application/json'

  def self.enforce_tls
    begin
      response = patch '/user/settings/enforced_tls', body: {require_tls: true}.to_json
    rescue SocketError => e
      Rails.logger.error e.message
      return false
    end
    response.success? and response['require_tls']
  end

  def self.dont_enforce_tls
    begin
      response = patch '/user/settings/enforced_tls', body: {require_tls: false, require_valid_cert: false}.to_json
    rescue SocketError => e
      Rails.logger.error e.message
      return false
    end
    response.success? and !response['require_tls']
  end

  def self.enforce_tls?
    response = get '/user/settings/enforced_tls'
    response['require_tls']
  end

end