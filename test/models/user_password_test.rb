require "test_helper"

describe UserPassword do
  let(:user_password) { UserPassword.new }

  it "must be valid" do
    value(user_password).must_be :valid?
  end
end
