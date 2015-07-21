require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  def setup
    @admin_user = users(:andrew)
    @pleb_user = users(:peter)
  end

  test "should get index" do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get :index, id: @admin_user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when no view permission" do
  	log_in_as(@pleb_user)
    get :index
    assert_redirected_to root_url
  end

end
