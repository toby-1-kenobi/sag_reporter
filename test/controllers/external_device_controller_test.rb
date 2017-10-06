require "test_helper"

describe ExternalDeviceController do
  it "should get send_request" do
    get :send_request
    value(response).must_be :success?
  end

  it "should get receive_request" do
    get :receive_request
    value(response).must_be :success?
  end

end
