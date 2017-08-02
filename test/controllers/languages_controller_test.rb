require 'test_helper'

describe LanguagesController do

  before do
    @national_user = users(:norman)
    @normal_user = users(:emma)
  end

  it 'redirects to login when not logged in user goes to language dashboard' do
    get :show, id: languages(:toto)
    assert_redirected_to login_path
  end

  it 'lets a user go to the language dashboard of a language in their state' do
    log_in_as(@normal_user)
    get :show, id: languages(:toto)
    _(response).must_be :success?
  end

  it 'lets a user go to the language details for a language in their state' do
    log_in_as(@normal_user)
    get :show_details, id: languages(:toto)
    _(response).must_be :success?
  end

  it 'wont let a user go to the language dashboard of a language not in their state' do
    log_in_as(@normal_user)
    get :show, id: languages(:gujarati)
    assert_redirected_to zones_path
  end

  it 'wont let a user go to the language details for a language not in their state' do
    log_in_as(@normal_user)
    get :show_details, id: languages(:gujarati)
    assert_redirected_to zones_path
  end

  it 'wont let a user go to the language details for a language not in their state' do
    log_in_as(@normal_user)
    get :show_details, id: languages(:gujarati)
    assert_redirected_to zones_path
  end

  it 'will let a national user go to the language dashboard of any language' do
    log_in_as(@national_user)
    get :show, id: languages(:gujarati)
    _(response).must_be :success?
  end

  it 'will let a national user go to the language details for any language' do
    log_in_as(@national_user)
    get :show_details, id: languages(:gujarati)
    _(response).must_be :success?
  end

end
