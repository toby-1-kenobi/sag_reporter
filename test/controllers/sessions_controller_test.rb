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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should send otp message on phone and show flash message" do
  	post :two_factor_auth, { session: { phone: "0987654323", password: "password" } }
  	assert_equal @twilio_user.id, session[:user_id]
		assert_equal 'OTP has been sent in your registered mobile number', flash['info']
  end

  test "should send otp both phone and email and show flash message" do
  	post :two_factor_auth, { session: { phone: "0987654323", password: "password" } }
  	assert_equal @twilio_user.id, session[:temp_user]
		assert_equal 'OTP has been sent in your registered mobile number and your registered email address.', flash['info']
  end

  test "should not send otp if user entered information" do
  	post :two_factor_auth, { session: { phone: "01987656329", password: "12345678" } }
		assert_response :success
		assert_equal 'Phone number or password not correct', flash['error']
	end

	test "should not send otp if user registetred with wrong phone number" do
		post :two_factor_auth, { session: { phone: "0987654321", password: "password" } }
		assert_equal @user.phone, "0987654321"
		assert_equal 'Something went wrong. Please enter valid phone number or check Internet connection.', flash['error']
	end

	test "should verify correct otp and flash message" do
		otp_code = @user.otp_code
		session[:temp_user] = @user.id
		post :verify_otp, { otp_code: otp_code }
		assert_response :success
		assert_equal "OTP verified successfully.", json_response['message']
	end

	test "should reject wrong otp and flash a message" do
		otp_code = @user.otp_code
		session[:temp_user] = @user.id
		post :verify_otp, { otp_code: 12897 }
		assert_response :success
		assert_equal "OTP has expired or you have entered wrong OTP. please click on resend OTP and try to login again.", json_response['message']
	end

	test "user should be able to resend otp in phone" do
		otp_code = @twilio_user_unconfirmed.otp_code
		session[:temp_user] = @twilio_user_unconfirmed.id
		get :resend_otp
		assert_response :success
		assert_equal "OTP has been sent in your registered mobile number", json_response['message']
	end

	test "user should be able to resend otp at both phone and mail with confirmed email " do
		otp_code = @twilio_user_confirmed.otp_code
		session[:temp_user] = @twilio_user_confirmed.id
		get :resend_otp
		assert_response :success
		assert_equal "OTP has been sent in your registered mobile number and your registered email address.", json_response['message']
	end


  test "should log in user and redirected to edit user page" do
		post :create, { session: { phone: "0987654321", password: "password" } }
		assert_redirected_to edit_user_path(@user)
		assert_equal 'Welcome to Last Command Initiative Reporter.' +
              ' Please make a new password. It should be something another person could not guess.' +
              ' Type it here two times and click \'update\'.', flash['info'] #flash notice test
  end

  test "user should login and redirect to home page" do
  	post :create, { session: { phone: "0987654322", password: "test12345678" } }
		assert_redirected_to root_path
		assert_equal @other_user.id, session[:user_id]
  end

  test "user should not able to login with wrong password" do
  	post :create, { session: { phone: "0987654322", password: "12345678" } }
		assert_response :success
		assert_equal 'Phone number or password not correct', flash['error']
  end

  test "user should not able to login with wrong phone number" do
  	post :create, { session: { phone: "0987656329", password: "12345678" } }
		assert_response :success
		assert_equal 'Phone number or password not correct', flash['error']
  end

end
