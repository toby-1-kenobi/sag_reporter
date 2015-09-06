require "test_helper"

describe OutputTalliesController do

  before do
    log_in_as(users(:andrew))
  end

  it "should get report_numbers" do
    get :report_numbers
    value(response).must_be :success?
  end

end
