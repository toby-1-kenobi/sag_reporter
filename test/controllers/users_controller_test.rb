require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def authenticate
    token = Knock::AuthToken.new(payload: { sub: @admin_user.id }).token
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
  end

  let(:some_state) { geo_states(:nb) }

  let(:user_params) { { :user => {
      name: 'test user',
      phone: '1357924680',
      password: 'PassWord123',
      password_confirmation: 'PassWord123',
      role_id: Role.take.id,
      mother_tongue_id: Language.take.id,
      geo_states: { some_state.id => some_state.id }
  } } }

  def setup
    @admin_user = users(:andrew)
    @normal_user = users(:emma)
  end

  def json_response
    ActiveSupport:: JSON.decode @response.body
  end

  test 'should get new' do
    log_in_as(@admin_user)
    get :new
    assert_response :success
    assert assigns :user
  end

  test 'should redirect new when not logged in' do
    get :new, id: @admin_user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when not logged in' do
    get :edit, id: @admin_user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch :update, id: @admin_user, user: {name: @admin_user.name, phone: @admin_user.phone }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not have permission' do
    log_in_as(@normal_user)
    patch :update, id: @admin_user, user: {name: @admin_user.name, phone: @admin_user.phone }
    assert_redirected_to root_url
  end

  test 'should redirect index when not logged in' do
    get :index
    assert_redirected_to login_url
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to login_url
  end

  test 'should redirect destroy when logged in as a non-admin' do
    log_in_as(@normal_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @admin_user
    end
    assert_redirected_to root_url
  end

  test 'should redirect create when not logged in' do
    assert_no_difference 'User.count' do
      post :create, user_params
    end
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect create when not admin' do
    log_in_as(@normal_user)
    assert_no_difference 'User.count' do
      post :create, user_params
    end
    assert_redirected_to root_url
  end

  it 'allows admin users to create new national admin users' do
    log_in_as(@admin_user)
    user_params[:user][:admin] = 'true'
    user_params[:user][:national] = 'true'
    assert_difference 'User.where(admin: true, national: true).count' do
      post :create, user_params
    end
  end

  it 'allows admin users to create new curator users' do
    log_in_as(@admin_user)
    user_params[:user][:curator] = 'true'
    assert_difference 'User.where(curator: true).count' do
      post :create, user_params
    end
  end

  # test "successful create" do
  #   log_in_as(@user)
  #   assert_difference 'User.count' do
  #     post :create, user: {
  #       name: "test user",
  #       phone: "9988776655",
  #       password:              "PassWord.123",
  #       password_confirmation: "PassWord.123",
  #       role_id: Role.take.id,
  #       mother_tongue_id: Language.take.id,
  #       interface_language_id: languages(:english).id
  #     }
  #   end
  #   assert_response :redirect
  # end

  test 'wont allow non-admin user to change own geo_state' do
    log_in_as(@normal_user)
    _(@normal_user.is_an_admin?).must_equal false
    states = GeoState.take 2
    @normal_user.geo_states.clear
    @normal_user.geo_states << states[0]
    _(@normal_user.geo_states).must_include states[0]
    _(@normal_user.geo_states).wont_include states[1]
    patch :update, id: @normal_user.id, user: {geo_states: {states[1].id => '1'} }
    @normal_user.reload
    _(@normal_user.geo_states).must_include states[0]
    _(@normal_user.geo_states).wont_include states[1]
  end

  test 'admin user can change own geo_state' do
    log_in_as(@admin_user)
    states = GeoState.take 2
    @admin_user.geo_states.clear
    @admin_user.geo_states << states[0]
    _(@admin_user.geo_states).must_include states[0]
    _(@admin_user.geo_states).wont_include states[1]
    patch :update, id: @admin_user.id, user: {geo_states: {states[1].id => '1'} }
    @admin_user.reload
    _(@admin_user.geo_states).wont_include states[0]
    _(@admin_user.geo_states).must_include states[1]
  end

  test "admin user can change another user's geo_state" do
    log_in_as(@admin_user)
    states = GeoState.take 2
    @normal_user.geo_states.clear
    @normal_user.geo_states << states[0]
    _(@normal_user.geo_states).must_include states[0]
    _(@normal_user.geo_states).wont_include states[1]
    patch :update, id: @normal_user.id, user: {geo_states: {states[1].id => '1'}, name: 'Updated name'}
    @normal_user.reload
    _(@normal_user.geo_states).must_include states[1]
    _(@normal_user.geo_states).wont_include states[0]
  end

  test 'get user data with token auth' do
    authenticate
    get :me
    response = ActiveSupport::JSON.decode @response.body
    assert_equal @admin_user.name, response['name']
    assert_equal @admin_user.phone, response['phone']
    assert_equal @admin_user.geo_states.count, response['geo_states'].count
  end

  test 'user can update profile with email' do
    log_in_as(@admin_user)
    patch :update, id: @admin_user.id, user: { email: "test123@example.com" }
    _(flash['success']).must_be :present?
    assert_redirected_to @admin_user
  end

  test 'verified user with confirmation token' do
    log_in_as(@admin_user)
    get :confirm_email, { id: @admin_user.confirm_token}
    _(flash['success']).must_be :present?
    assert_redirected_to root_path
  end

  test 'resend confirm email to user' do
    log_in_as(@admin_user)
    get :re_confirm_email
    assert_not_nil json_response['message']
    assert_response :success
  end

end
