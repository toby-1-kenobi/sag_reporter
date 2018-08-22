require "test_helper"

describe RegistrationApproval do
  let(:registration_approvals) { RegistrationApproval.new }

  it "must be valid" do
    value(registration_approvals).must_be :valid?
  end
end
