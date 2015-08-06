require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  def setup
    @user = users(:andrew)
  end

  test "should get home" do
  	log_in_as(@user)
    get :home
    assert_response :success
    assert_select "title", "Home | Last Command reporter"
  end

end
