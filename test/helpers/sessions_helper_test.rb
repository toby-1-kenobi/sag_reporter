require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:andrew)
    remember(@user)
  end

  test "logged_in_user returns right user when session is nil" do
    assert_equal @user, logged_in_user
    assert is_logged_in?
  end

  test "logged_in_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil logged_in_user
  end
  
end