require "test_helper"

describe GeoStatesController do

  let(:geo_state) { FactoryBot.create(:geo_state) }

  before do
    @national_user = FactoryBot.build(:user, national: true)
    @normal_user = FactoryBot.build(:user)
    @normal_user.geo_states << geo_state
  end

  it 'redirects to login when not logged in user goes to state dashboard' do
    get :show, id: geo_state
    assert_redirected_to login_path
  end

  it 'lets user go to own state dashboard' do
    log_in_as @normal_user
    get :show, id: geo_state
    _(response).must_be :success?
  end

  it 'wont let users go to dashboard of a state they are not in' do
    log_in_as @normal_user
    other_state = FactoryBot.create(:geo_state)
    _(@normal_user.geo_states).wont_include other_state
    get :show, id: other_state
    assert_redirected_to zones_path
  end

  it 'lets national users go to any state dashboard' do
    log_in_as @national_user
    other_state = FactoryBot.create(:geo_state)
    _(@national_user.geo_states).wont_include other_state
    get :show, id: other_state
    _(response).must_be :success?
  end

end
