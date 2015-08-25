require "test_helper"

describe OutputTalliesController do
  it "should get report_numbers" do
    get :report_numbers
    value(response).must_be :success?
  end

end
