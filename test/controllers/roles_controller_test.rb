require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  def setup
    @admin_user = users(:andrew)
    @pleb_user = users(:peter)
  end

  test 'should get index' do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end

  test 'should redirect index when not logged in' do
    get :index, id: @admin_user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect index when no view permission' do
  	log_in_as(@pleb_user)
    get :index
    assert_redirected_to root_url
  end

  it 'wont let admin role lose vital permissions' do
    log_in_as(@admin_user)
    patch :update, roles: {'admin' => {}}
    admin_role = Role.find_by_name 'admin'
    value(admin_role.permissions.count).must_equal 2
    value(admin_role.permissions).must_include Permission.find_by_name 'view_roles'
    value(admin_role.permissions).must_include Permission.find_by_name 'edit_role'
  end

  # this test uses only minitest's limited built in mocking and stubbing
  it 'destroys a role with no users' do
    mock_user_collection = Minitest::Mock.new
    mock_user_collection.expect :count, 0

    mock_role = Minitest::Mock.new
    mock_role.expect :users, mock_user_collection
    mock_role.expect :destroy, true

    log_in_as(@admin_user)
    Role.stub(:find, mock_role) do
      # id doesn't matter - mock_role will always be returned
      delete :destroy, id: 10
    end
    value(mock_role).must_be :verify
  end

  # This test uses Mocha
  it "doesn't destroy a role with users" do
    role_id = '11'
    role_double = Role.new
    role_double.stubs(:users).returns([User.new]) # this role has a user
    role_double.expects(:destroy).never
    Role.stubs(:find).with(role_id).returns(role_double)

    log_in_as(@admin_user)
    delete :destroy, id: role_id
  end

end
