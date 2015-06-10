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

end
