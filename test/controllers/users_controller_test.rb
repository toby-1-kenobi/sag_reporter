require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:andrew)
    @other_user = users(:peter)
  end

  test "should get new" do 	
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, phone: @user.phone }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not have permission" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { name: @user.name, phone: @user.phone }
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "should redirect create when not logged in" do
    post :create, user: {
      name: @user.name,
      phone: @user.phone,
      password:              "PassWord.123",
      password_confirmation: "PassWord.123",
      role_id: Role.all.first.id
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect createe when not have permission" do
    log_in_as(@other_user)
    post :create, user: {
      name: @user.name,
      phone: @user.phone,
      password:              "PassWord.123",
      password_confirmation: "PassWord.123",
      role_id: Role.all.first.id
    }
    assert_redirected_to root_url
  end

end
