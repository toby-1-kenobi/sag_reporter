require "test_helper"

describe PbApiController do
  it "should get jwt" do
    get :jwt
    value(response).must_be :success?
  end

end
