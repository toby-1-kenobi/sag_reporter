require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
  end

  test "should get home" do
  	log_in_as(@user)
    get :home
    assert_response :success
    assert_select "title", "Home | NBASE reporter"
  end

end
