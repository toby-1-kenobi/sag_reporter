require 'test_helper'

class UsersCreateTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get adduser_path
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               phone: "1234",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "valid user create" do
    get adduser_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name:  "Example User",
                                            phone: "1029384756",
                                            password:              "PassWord.123",
                                            password_confirmation: "PassWord.123" }
    end
    assert_template 'users/show'
  end

end
