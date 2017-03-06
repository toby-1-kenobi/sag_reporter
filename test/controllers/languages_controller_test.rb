require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase

  def setup
    @lang = languages(:toto)
    @admin_user = users(:andrew)
    @national_curator = users(:nathan)
  end
  
  test "should get index" do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

  test "should get new" do
    log_in_as(@national_curator)
    get :new
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@national_curator)
    get :edit, id: @lang
    assert_response :success
  end

  test "should get show" do
    log_in_as(@admin_user)
    get :show, id: @lang
    assert_response :success
  end

end
