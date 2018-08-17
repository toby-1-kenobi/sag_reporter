require "test_helper"

describe RegistrationApprovals do
  let(:registration_approvals) { RegistrationApprovals.new }

  it "must be valid" do
    value(registration_approvals).must_be :valid?
  end
end
