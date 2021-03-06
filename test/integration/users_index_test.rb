require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

	include IntegrationHelper

  def setup
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    @admin_user = FactoryBot.create(:user, admin: true)
    @view_user = FactoryBot.create(:user)
  end

  test "index including pagination and delete links" do
    log_in_as(@admin_user)
    get users_path
    assert_template 'users/index'
    assert_select 'ul.pagination'
    User.order("LOWER(name)").paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      if user == @admin_user
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
