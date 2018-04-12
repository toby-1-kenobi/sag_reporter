class PbApiController < ApplicationController
  include JwtConcern

  skip_before_action :verify_authenticity_token

  def jwt
    user = User.find_by_email params[:email]
    if user
      if user.authenticate(params[:password])
        jwt = encode_jwt({'user_id' => user.id})
        render json: { status: 'success', token: jwt }
      else
        render json: { status: 'fail', error: 'bad password'}
      end
    else
      render json: { status: 'fail', error: 'unknown email'}
    end
  end

  def language_details
  end

end
