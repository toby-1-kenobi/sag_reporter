require 'test_helper'

class UsersCreateTest < ActionDispatch::IntegrationTest

	include IntegrationHelper

  def setup
    @admin = users(:andrew)
  end
  
  test "invalid user create" do
    log_in_as(@admin)
    get adduser_path
    assert_template 'users/new'
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
    log_in_as(@admin)
    get adduser_path
    assert_template 'users/new'
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name:  "Example User",
                                            phone: "1029384756",
                                            password:              "PassWord123",
                                            password_confirmation: "PassWord123",
                                            role_id: Role.take.id,
                                            mother_tongue_id: Language.take.id,
																					  geo_states: [GeoState.take.id],
                                            interface_language_id: Language.take.id
                                          }
    end
    assert_template 'users/show'
		assert_not_equal nil, flash['success']
		assert_equal nil, flash['error']
  end

end
