class SignupController < ApplicationController

  include UsersHelper

  def new
    @geo_states = GeoState.where(id: params[:signup][:id])
    @zones = Zone.includes(:geo_states => {:geo_states_users => :users}).where('users.regitrstion_status' => 0)
    @user = User.new(name:params[:signup][:name],phone:params[:signup][:phone], email:params[:signup][:email],
                     role_description:params[:signup][:role_description],
                     mother_tongue_id:params[:signup][:interface_language_id], registration_status:0,
                     password:'asfafaf', geo_states:@geo_states)
    if @user.save
      user_registration_request_mail(@geo_states, params[:authenticity_token])
    else
       render 'new'
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

