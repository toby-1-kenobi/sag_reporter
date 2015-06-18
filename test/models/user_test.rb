require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", phone: "9876543210", password: "foobar", password_confirmation: "foobar")
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
  test "phone number should be length 10" do
    @user.phone = "1" * 11
    assert_not @user.valid?
    @user.phone = "1" * 9
    assert_not @user.valid?
  end

  test "phone number should be only digits" do
    @user.phone = "a" * 10
    assert_not @user.valid?
    @user.phone = "+123456789"
    assert_not @user.valid?
    @user.phone = "1234 56789"
    assert_not @user.valid?
  end

  test "phone numbers should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should not be blank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

end
