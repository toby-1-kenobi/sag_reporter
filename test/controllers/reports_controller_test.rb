require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  def setup
    @admin_user = users(:andrew)
    @pleb_user = users(:peter)
    @report = reports("report-1")
  end

  test "should get new" do
    log_in_as(@admin_user)
    get :new
    assert_response :success
  end

  test "should get reports by language" do
    log_in_as(@admin_user)
    get :by_language
    assert_response :success
  end

  test "should get reports by topic" do
    log_in_as(@admin_user)
    get :by_topic
    assert_response :success
  end

  test "should get reports by reporter" do
    log_in_as(@admin_user)
    get :by_reporter
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@admin_user)
    get :edit, id: @report
    assert_response :success
  end

  test "should get index" do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

end
