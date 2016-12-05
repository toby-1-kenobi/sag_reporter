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

end
