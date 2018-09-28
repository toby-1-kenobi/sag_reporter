require "test_helper"

describe ProjectSupervisorsController do
  it "should get create" do
    post :create, format: :js
    value(response).must_be :success?
  end

  it "should get destroy" do
    ps = FactoryBot.create(:project_supervisor)
    _(ps).must_be :persisted?
    delete :destroy, id: ps.id, format: :js
    value(response).must_be :success?
    _(ps).wont_be :persisted?
  end

end
