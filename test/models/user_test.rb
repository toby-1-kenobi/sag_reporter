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

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  # In India mobile phone numbers are 10 digits
  test "phone number should not be too long" do
    @user.phone = "1" * 11
    assert_not @user.valid?
  end

  test "phone number should not be too short" do
    @user.phone = "1" * 9
    assert_not @user.valid?
  end

end
