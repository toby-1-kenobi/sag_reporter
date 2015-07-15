require 'test_helper'

class RolesIndexTestTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:andrew)
    @view_user = users(:vera)
  end

  test "index including create and update links" do
    log_in_as(@user)
    get roles_path
    assert_template 'roles/index'
    # new role button
    assert_select 'button[data-target=new_role_modal]'
    # update roles button
    assert_select 'button[type=submit]', text: "Update"
  end

  test "index without create and update links" do
    log_in_as(@view_user)
    get roles_path
    assert_template 'roles/index'
    # new role button
    assert_select 'button[data-target=new_role_modal]', count: 0
    # update roles button
    assert_select 'button[type=submit]', text: "Update", count: 0
  end

end
