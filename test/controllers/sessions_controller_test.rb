require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
	def setup
		@user = users(:andrew)
		@other_user = users(:emma)
		@twilio_user_unconfirmed = users(:twilio_user_unconfirmed)
		@twilio_user_confirmed = users(:twilio_user_confirmed)
  end

  def json_response
		ActiveSupport:: JSON.decode @response.body
	end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should send otp message on phone and show flash message' do
  	post :two_factor_auth, { session: {phone: @twilio_user_unconfirmed.phone, password: 'password'} }
  	assert_equal @twilio_user_unconfirmed.id, session[:user_id]
		value(flash['info']).wont_be_nil
  end

  test 'should send otp both phone and email and show flash message' do
  	post :two_factor_auth, { session: {phone: @twilio_user_unconfirmed.phone, password: 'password'} }
  	assert_equal @twilio_user_unconfirmed.id, session[:temp_user]
		value(flash['info']).wont_be_nil
  end

  test 'should not send otp if user entered bad credentials' do
  	post :two_factor_auth, { session: {phone: @user.phone, password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
	end

	test 'should verify correct otp and flash message' do
		otp_code = @user.otp_code
		session[:temp_user] = @user.id
		post :verify_otp, { otp_code: otp_code }
		assert_response :success
		value(json_response['message']).wont_be_nil
	end

	test 'should reject wrong otp and flash a message' do
		session[:temp_user] = @user.id
		post :verify_otp, { otp_code: 12897 }
		assert_response :success
		value(json_response['message']).wont_be_nil
	end

	test 'user should be able to resend otp in phone' do
		session[:temp_user] = @twilio_user_unconfirmed.id
		get :resend_otp
		assert_response :success
		value(json_response['message']).wont_be_nil
	end

	test 'user should be able to resend otp at both phone and mail with confirmed email ' do
		session[:temp_user] = @twilio_user_confirmed.id
		get :resend_otp
		assert_response :success
	end


  test 'should log in user and redirected to edit user page' do
		post :create, { session: {phone: '0987654321', password: 'password'} }
		assert_redirected_to edit_user_path(@user)
		value(flash['info']).wont_be_nil
  end

  test 'user should login and redirect to home page' do
  	post :create, { session: {phone: '0987654322', password: 'test12345678'} }
		assert_redirected_to root_path
		assert_equal @other_user.id, session[:user_id]
  end

  test 'user should not able to login with wrong password' do
  	post :create, { session: {phone: '0987654322', password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
  end

  test 'user should not able to login with wrong phone number' do
  	post :create, { session: {phone: '0987656329', password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
  end

end
