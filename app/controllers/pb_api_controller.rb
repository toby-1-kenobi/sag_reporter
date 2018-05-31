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
    render json: { status: 'fail', error: 'not authorised' } and return unless request.headers['Authorization']
    token = request.headers['Authorization'].split.last
    payload = {}
    begin
      payload = decode_jwt(token)
    rescue JWT::VerificationError
      render json: { status: 'fail', error: 'corrupt authorisation token' } and return
    end
    render json: { status: 'fail', error: 'wrong authorisation token' } and return unless payload['user_id']
    render json: { status: 'fail', error: 'user not found' } and return unless User.find payload['user_id']
    language = Language.find_by_iso params[:iso]
    render json: { status: 'fail', error: 'language not found', iso: params[:iso] } and return unless language
    language_details =  { iso: language.iso, name: language.name }
    markers_of_interest = [5, 6, 7, 2, 1]
    finish_line_progresses = language.finish_line_progresses.includes(:finish_line_marker).where( finish_line_markers: { number: markers_of_interest}, year: nil)
    finish_line_progresses.each do |flp|
      language_details[flp.finish_line_marker.name] = flp.status
    end
    render json: {
        status: 'success',
        language: language_details
    }
  end

end
