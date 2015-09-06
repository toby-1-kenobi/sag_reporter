require 'test_helper'

class TopicsControllerTest < ActionController::TestCase

  def setup
    @admin_user = users(:andrew)
    @pleb_user = users(:peter)
    @education = topics(:social_development)
  end

  test "should get new" do
    log_in_as(@admin_user)
    get :new
    assert_response :success
  end

  test "should get index" do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

  test "should get show" do
    log_in_as(@admin_user)
    get :show, id: @education
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@admin_user)
    get :edit, id: @education
    assert_response :success
  end

end
