require "test_helper"

describe QuarterlyTarget do
  let(:quarterly_target) { FactoryBot.build(:quarterly_target) }

  it "must be valid" do
    value(quarterly_target).must_be :valid?
  end
end
