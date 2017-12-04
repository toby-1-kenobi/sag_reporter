require 'test_helper'

describe EventsController do

  before do
    log_in_as(users(:andrew))
  end

  it "should get new" do
    get :new
    value(response).must_be :success?
  end

end
