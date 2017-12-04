require 'test_helper'

describe ZonesController do

  before do
    @national_user = users(:norman)
    @normal_user = users(:emma)
  end

  it 'should get index when logged in' do
    log_in_as(@normal_user)
    get :index
    value(response).must_be :success?
  end

  it 'should redirect from index when not logged in' do
    get :index
    _(flash).wont_be :empty?
    assert_redirected_to login_path
  end

  it 'should get nation page for national user' do
    log_in_as(@national_user)
    get :nation
    value(response).must_be :success?
  end

  it 'should redirect to zone map when non national user goes to nation page' do
    log_in_as @normal_user
    get :nation
    assert_redirected_to zones_path
  end

  it 'should redirect to login when not logged in goes to nation page' do
    get :nation
    assert_redirected_to login_path
  end

  it 'should redirect to login when not logged in goes to zone dashboard' do
    get :show, id: zones(:west)
    assert_redirected_to login_path
  end

  it 'should let user go to own zone dashboard' do
    log_in_as @normal_user
    get :show, id: zones(:north_east)
    _(response).must_be :success?
  end

  it 'wont let users go to dashboard of a zone they are not in' do
    log_in_as @normal_user
    get :show, id: zones(:west)
    assert_redirected_to zones_path
  end

  it 'should let national users go to any zone dashboard' do
    log_in_as @national_user
    get :show, id: zones(:west)
    _(response).must_be :success?
  end

end
