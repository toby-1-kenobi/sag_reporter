require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

	include IntegrationHelper

  def setup
    @english = FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    @admin_user = FactoryBot.create(:user, admin: true)
    @pleb_user = FactoryBot.create(:user)
  end

  test "unsuccessful edit" do
    log_in_as(@admin_user)
    get edit_user_path(@admin_user)
    assert_template 'users/edit'
    patch user_path(@admin_user), user: {name:  "",
                                               phone: "55555",
                                               password:              "foo",
                                               password_confirmation: "bar" }
    assert_template 'users/edit'
  end


  test "successful edit self with friendly forwarding" do
    get edit_user_path(@admin_user)
    log_in_as(@admin_user)
    assert_redirected_to edit_user_path(@admin_user)
    name  = "Foo Bar"
    phone = "1010101010"
    patch user_path(@admin_user), user: {name:  name,
                                               phone: phone,
                                               password:              "",
                                               password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @admin_user
    @admin_user.reload
    assert_equal name, @admin_user.name
    assert_equal phone, @admin_user.phone
  end

end
