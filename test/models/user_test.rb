require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", phone: "9876543210")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "blank name is invalid" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "blank phone is invalid" do
    @user.phone = "     "
    assert_not @user.valid?
  end

end
