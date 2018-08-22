class SignupController < ApplicationController

  include UsersHelper

  def new
    @geo_states = GeoState.where(id: params[:signup][:id])
    @zones = Zone.includes(:geo_states => {:geo_states_users => :users}).where('users.regitrstion_status' => 0)
    rand_password=(('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a).shuffle.first(8).join #random password generator
    @user = User.new(name:params[:signup][:name],phone:params[:signup][:phone], email:params[:signup][:email],
                     role_description:params[:signup][:role_description],
                     mother_tongue_id:params[:signup][:interface_language_id], registration_status:0,
                     password: rand_password, geo_states:@geo_states)

    if !verify_recaptcha(model: @user)
      flash[:error] = 'Not match captcha'
      render 'sessions/signup'
    else
      if @user.save
        user_registration_request_mail(@geo_states, params[:authenticity_token])
      else
        flash[:error] = 'Unable to create new user'
        render 'sessions/signup'
      end
    end

  end

 def user_registration_request_mail(states, token)
    zones = Hash.new
    states.each do |state|
      if not zones.has_key?(state.zone_id)
        zones[state.zone_id] = state.zone_id
      end
    end
    zones.keys.each do |zone_id|
      curators = User.includes(:geo_states).where(registration_curator: true, geo_states: {zone_id: zone_id}).order(:name)
      curators.each do |curator|
        @mail_sent = send_registration_request(curator, token)
      end
    end
    render 'sessions/signup_user'
 end

 end

