require "test_helper"

describe MinistryOutput do
  let(:ministry_output) { FactoryBot.build(:ministry_output) }

  it "must be valid" do
    value(ministry_output).must_be :valid?
  end
end
