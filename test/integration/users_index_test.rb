require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

	include IntegrationHelper

  def setup
    @user = users(:andrew)
    @view_user = users(:vera)
  end

  test "index including pagination and delete links" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'ul.pagination'
    User.order("LOWER(name)").paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      if user == @user
        # no delete link for self
        assert_select 'a[href=?][data-method=delete]', user_path(user), count: 0
      else
        assert_select 'a[href=?][data-method=delete]', user_path(user)
      end
    end
  end

  test "index without delete links" do
    log_in_as(@view_user)
    get users_path
    User.order("LOWER(name)").paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?][data-method=delete]', user_path(user), count: 0
    end
  end

end
