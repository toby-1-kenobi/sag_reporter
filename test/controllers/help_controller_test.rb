require "test_helper"

describe HelpController do
  it "should get edit_language" do
    get :edit_language
    value(response).must_be :success?
  end

end
