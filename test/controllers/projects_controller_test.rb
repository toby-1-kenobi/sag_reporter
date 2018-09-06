require "test_helper"

describe ProjectsController do

  let(:admin_user) { FactoryBot.create(:user, admin: true) }

  before do
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end

  it "should get index" do
    log_in_as(admin_user)
    get :index
    value(response).must_be :success?
  end

  it "should get create" do
    log_in_as(admin_user)
    post :create, project: { name: 'test' }, format: :js
    value(response).must_be :success?
  end

end
