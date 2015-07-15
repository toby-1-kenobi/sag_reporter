require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  def setup
    @user = users(:andrew)
  end

  test "should get index" do 	
    log_in_as(@user)
    get :index
    assert_response :success
  end

end
