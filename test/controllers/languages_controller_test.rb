require 'test_helper'

describe LanguagesController do

  let(:language) { FactoryBot.create(:language) }
  let(:other_language) { FactoryBot.create(:language) }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    @admin_user = FactoryBot.create(:user, admin: true)
    @normal_user = FactoryBot.create(:user)
    @normal_user.geo_states << language.geo_states
    @national_user = FactoryBot.create(:user, national: true)
  end

  it 'redirects to login when not logged in user goes to language dashboard' do
    get :show, id: language
    assert_redirected_to login_path
  end

  it 'lets a user go to the language dashboard of a language in their state' do
    log_in_as(@normal_user)
    get :show, id: language
    _(response).must_be :success?
  end

  it 'lets a user go to the language details for a language in their state' do
    flm = FactoryBot.build(:finish_line_marker)
    FinishLineMarker.stub :find_by_number, flm do
      log_in_as(@normal_user)
      get :show_details, id: language
      _(response).must_be :success?
    end
  end

  it 'wont let a user go to the language dashboard of a language not in their state' do
    log_in_as(@normal_user)
    get :show, id: other_language
    assert_redirected_to zones_path
  end

  it 'wont let a user go to the language details for a language not in their state' do
    log_in_as(@normal_user)
    get :show_details, id: other_language
    assert_redirected_to zones_path
  end

  it 'wont let a user go to the language details for a language not in their state' do
    log_in_as(@normal_user)
    get :show_details, id: other_language
    assert_redirected_to zones_path
  end

  it 'will let a national user go to the language dashboard of any language' do
    log_in_as(@national_user)
    get :show, id: other_language
    _(response).must_be :success?
  end

  it 'will let a national user go to the language details for any language' do
    flm = FactoryBot.build(:finish_line_marker)
    FinishLineMarker.stub :find_by_number, flm do
      log_in_as(@national_user)
      get :show_details, id: other_language
      _(response).must_be :success?
    end
  end

  it 'must let an admin user set the language champion' do
    log_in_as(@admin_user)
    champ = User.take
    xhr :patch, :set_champion, id: language, champion: champ.name
    _(response).must_be :success?
  end

  it 'wont let a non admin user set the language champion' do
    log_in_as(@normal_user)
    champ = User.take
    xhr :patch, :set_champion, id: language, champion: champ.name
    _(response).wont_be :success?
  end

end
