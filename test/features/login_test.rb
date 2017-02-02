require "test_helper"

feature 'Login' do

  def setup
    Capybara.current_driver = :poltergeist
    @user = users(:andrew)
  end

  scenario 'user can resend login code to phone' do
    BcsSms.expects(:send_otp).returns({'status' => true}).twice
    visit login_path
    fill_in 'session_phone', with: @user.phone
    fill_in 'session_password', with: 'password'
    find('button').click
    find('.resend_otp_to_phone').click
  end

  def teardown
    Capybara.use_default_driver
  end

end
