require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
	def setup
		@admin_user = FactoryBot.create(:user, admin: true)
		@normal_user = FactoryBot.create(:user)
		@user_email_unconfirmed = FactoryBot.create(:user, email_confirmed: false)
		@user_email_confirmed = FactoryBot.create(:user, email_confirmed: true)
  end

  def json_response
		ActiveSupport:: JSON.decode @response.body
	end

  test 'should get new' do
    get :new
    assert_response :success
	end

	test 'wont let users skip OTP' do
		post :create, { session: {phone: @admin_user.phone, password: 'password'} }
    assert_not_equal session[:user_id], @admin_user.id
	end

  # SMS server and mailer need to be mocked for these tests
  test 'should send otp message on phone and show flash message' do
		BcsSms.expects(:send_otp).returns({'status' => true})
  	post :two_factor_auth, { session: {username: @user_email_unconfirmed.phone, password: 'password'} }
    assert_equal session[:temp_user], @user_email_unconfirmed.id
		value(flash['info']).wont_be_nil
  end

  test 'should show error message if phone and email cannot receive OTP' do
    BcsSms.expects(:send_otp).returns({'status' => false})
  	post :two_factor_auth, { session: {username: @user_email_unconfirmed.phone, password: 'password'} }
  	assert_equal @user_email_unconfirmed.id, session[:temp_user]
		value(flash['error']).wont_be_nil
  end

	# test 'should verify correct otp and flash message' do
	# 	otp_code = @admin_user.otp_code
	# 	session[:temp_user] = @admin_user.id
	# 	post :verify_otp, { otp_code: otp_code }
	# 	assert_response :success
	# 	value(json_response['message']).wont_be_nil
	# end
  #
	# test 'should reject wrong otp and flash a message' do
	# 	session[:temp_user] = @admin_user.id
	# 	post :verify_otp, { otp_code: 12897 }
	# 	assert_response :success
	# 	value(json_response['message']).wont_be_nil
	# end

  test 'should log in user and redirected to edit user page to change password' do
    session[:temp_user] = @admin_user.id
		post :create, { session: { otp_code: @admin_user.otp_code.to_s } }
		assert_redirected_to edit_user_path(@admin_user)
		value(flash['info']).wont_be_nil
  end

  test 'user should login and redirect to home page' do
    session[:temp_user] = @normal_user.id
  	post :create, { session: { otp_code: @normal_user.otp_code.to_s } }
		assert_redirected_to root_path
		assert_equal @normal_user.id, session[:user_id]
  end

  test 'user should not able to login with wrong phone number' do
  	post :two_factor_auth, { session: {username: '0987656329', password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
  end

	test 'user should not able to login with wrong password' do
		post :two_factor_auth, { session: {username: '0987654322', password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
	end

  it 'sends otp message on phone and show flash message' do
    BcsSms.expects(:send_otp).returns({'status' => true})
  	post :two_factor_auth, { session: {username: @user_email_unconfirmed.phone, password: 'password'} }
  	assert_equal @user_email_unconfirmed.id, session[:temp_user]
		value(flash['info']).wont_be_nil
  end

  test 'should send otp both phone and email and show flash message' do
    BcsSms.expects(:send_otp).returns({'status' => true})
  	post :two_factor_auth, { session: {username: @user_email_confirmed.phone, password: 'password'} }
  	assert_equal @user_email_confirmed.id, session[:temp_user]
		value(flash['info']).wont_be_nil
  end

  test 'should not send otp if user entered bad credentials' do
    BcsSms.expects(:send_otp).never
  	post :two_factor_auth, { session: {username: @admin_user.phone, password: '12345678'} }
		assert_response :success
		value(flash['error']).wont_be_nil
	end

	test 'user should be able to resend otp to phone' do
    BcsSms.expects(:send_otp).returns({'status' => true})
		session[:temp_user] = @user_email_unconfirmed.id
		get :resend_otp_to_phone, format: :js
		assert_response :success
	end

	test 'user should be able to resend otp to mail with confirmed email' do
		session[:temp_user] = @user_email_confirmed.id
		get :resend_otp_to_email, format: :js
		assert_response :success
	end

end
