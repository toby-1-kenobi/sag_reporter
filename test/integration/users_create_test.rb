require 'test_helper'

class UsersCreateTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
  
  test "invalid user create" do
    log_in_as(@user)
    get adduser_path
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               phone: "1234",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'ul#error-list'
  end

  test "valid user create" do
    log_in_as(@user)
    get adduser_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name:  "Example User",
                                            phone: "1029384756",
                                            password:              "PassWord.123",
                                            password_confirmation: "PassWord.123" }
    end
    assert_template 'users/show'
    assert_not flash.empty?
  end

end
