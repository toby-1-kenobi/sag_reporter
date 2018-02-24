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

  it 'parses the filter parameter' do
    log_in_as @normal_user
    get :show, id: zones(:north_east), filter: '3,4,5-234-246-123'
    parsed = {'3' => %w(2 3 4), '4' => %w(2 4 6), '5' => %w(1 2 3)}
    assigns(:flm_filters).must_equal parsed
  end

  it 'uses default filters' do
    log_in_as @normal_user
    get :show, id: zones(:north_east)
    default = {
        '1' => %w(0 1 2 3 4 5 6),
        '2' => %w(0 1 2 3 4 5 6),
        '4' => %w(0 1 2 3 4 5 6),
        '5' => %w(0 1 2 3 4 5 6),
        '6' => %w(0 1 2 3 4 5 6),
        '7' => %w(0 1 2 3 4 5 6),
        '8' => %w(0 1 2 3 4 5 6),
        '9' => %w(0 1 2 3 4 5 6)
    }
    assigns(:flm_filters).must_equal default
  end

end
