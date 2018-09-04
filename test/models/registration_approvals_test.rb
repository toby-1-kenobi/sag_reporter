require "test_helper"

describe RegistrationApproval do
  let(:registration_approvals) { FactoryBot.build(:registration_approval) }

  it "must be valid" do
    value(registration_approvals).must_be :valid?
  end
end
