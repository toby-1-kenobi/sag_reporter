require "test_helper"

describe EditsController do
  it "should get create" do
    get :create, format: :js
    value(response).must_be :success?
  end

end
