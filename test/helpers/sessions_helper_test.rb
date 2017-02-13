require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @admin_user = users(:andrew)
    remember(@admin_user)
  end

  test "logged_in_user returns right user when session is nil" do
    assert_equal @admin_user, logged_in_user
    assert is_logged_in?
  end

  test "logged_in_user returns nil when remember digest is wrong" do
    @admin_user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil logged_in_user
  end
  
end