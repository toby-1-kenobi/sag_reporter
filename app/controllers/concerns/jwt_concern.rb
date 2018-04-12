module JwtConcern
  extend ActiveSupport::Concern

  private

  def encode_jwt(payload)
    secret_key = Rails.application.secrets.secret_key_base
    JWT.encode payload, secret_key, 'HS256'
  end

  def decode_jwt(token)
    secret_key = Rails.application.secrets.secret_key_base
    payload, _ = JWT.decode token, secret_key, true, {algorithm: 'HS256'}
    return payload
  end

end