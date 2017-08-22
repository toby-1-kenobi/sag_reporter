require "test_helper"

describe GeoStatesController do

  before do
    @national_user = users(:norman)
    @normal_user = users(:emma)
  end

  it 'redirects to login when not logged in user goes to state dashboard' do
    get :show, id: geo_states(:nb)
    assert_redirected_to login_path
  end

  it 'lets user go to own state dashboard' do
    log_in_as @normal_user
    get :show, id: geo_states(:nb)
    _(response).must_be :success?
  end

  it 'wont let users go to dashboard of a state they are not in' do
    log_in_as @normal_user
    _(@normal_user.geo_states).wont_include geo_states(:gujarat)
    get :show, id: geo_states(:gujarat)
    assert_redirected_to zones_path
  end

  it 'lets national users go to any state dashboard' do
    log_in_as @national_user
    _(@national_user.geo_states).wont_include geo_states(:gujarat)
    get :show, id: geo_states(:gujarat)
    _(response).must_be :success?
  end

end
