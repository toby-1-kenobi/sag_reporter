require 'test_helper'

class UsersCreateTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:andrew)
  end
  
  test "invalid user create" do
    log_in_as(@user)
    get adduser_path
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               phone: "1234",
                               password:              "foo",
                               password_confirmation: "bar",
                               role_id: Role.take.id,
                               mother_tongue_id: Language.take.id,
                               geo_state_id: GeoState.take.id,
                               interface_language_id: languages(:english).id
                             }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'ul#error-list'
  end

  test "valid user create" do
    log_in_as(@user)
    get adduser_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name:  "Example User",
                                            phone: "1029384756",
                                            password:              "PassWord.123",
                                            password_confirmation: "PassWord.123",
                                            role_id: Role.take.id,
                                            mother_tongue_id: Language.take.id,
                                            geo_state_id: GeoState.take.id,
                                            interface_language_id: languages(:english).id
                                          }
    end
    assert_template 'users/show'
    assert_not flash.empty?
  end

end
