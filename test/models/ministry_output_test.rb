require "test_helper"

describe MinistryOutput do
  let(:ministry_output) { FactoryBot.build(:ministry_output) }

  it "must be valid" do
    value(ministry_output).must_be :valid?
  end

  it "wont have a ministry marker not belonging to it's ministry" do
    ministry_output.ministry_marker = FactoryBot.build(:ministry_marker)
    value(ministry_output).wont_be :valid?
  end
end
