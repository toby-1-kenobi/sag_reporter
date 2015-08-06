require 'test_helper'

class TalliesControllerTest < ActionController::TestCase
  
  setup do
    @tally = tallies(:books)
    @user = users(:andrew)
    log_in_as(@user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tallies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tally" do
    assert_difference('Tally.count') do
      post :create, tally: { description: @tally.description, name: @tally.name }
    end

    assert_redirected_to tally_path(assigns(:tally))
  end

  test "should show tally" do
    get :show, id: @tally
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tally
    assert_response :success
  end

#  test "should update tally" do
#    patch :update, id: @tally, tally: { description: @tally.description, name: @tally.name }
#    assert_redirected_to tally_path(assigns(:tally))
#  end

end
