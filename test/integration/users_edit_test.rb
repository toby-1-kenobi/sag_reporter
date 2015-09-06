require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:andrew)
    @pleb_user = users(:peter)
    @english = languages(:english)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:  "",
                                    phone: "55555",
                                    password:              "foo",
                                    password_confirmation: "bar",
                                    mother_tongue_id: @english.id }
    assert_template 'users/edit'
  end

  test "cannot edit own role" do
    log_in_as(@user)
    get edit_user_path(@user)
    role = @user.role
    patch user_path(@user), user: { name:  @user.name,
                                    phone: @user.phone,
                                    password:              "",
                                    password_confirmation: "",
                                    role_id: @pleb_user.role.id,
                                    mother_tongue_id: @english.id
                                  }
    @user.reload
    assert_equal role,  @user.role
  end

  test "successful edit role of other user" do
    log_in_as(@user)
    get edit_user_path(@pleb_user)
    patch user_path(@pleb_user), user: { name:  @pleb_user.name,
                                    phone: @pleb_user.phone,
                                    password:              "",
                                    password_confirmation: "",
                                    role_id: @user.role.id,
                                    mother_tongue_id: @english.id
                                  }
    assert_not flash.empty?
    assert_redirected_to @pleb_user
    @pleb_user.reload
    assert_equal @pleb_user.role,  @user.role
  end

  test "successful edit self with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = "Foo Bar"
    phone = "1010101010"
    patch user_path(@user), user: { name:  name,
                                    phone: phone,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal phone, @user.phone
  end

end