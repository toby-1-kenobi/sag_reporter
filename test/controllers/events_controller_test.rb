require 'test_helper'

describe EventsController do

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
    admin_user = FactoryBot.create(:user, admin: true)
    log_in_as(admin_user)
  end

  it "should get new" do
    get :new
    value(response).must_be :success?
  end

end
