require "test_helper"

describe AggregateQuarterlyTarget do
  let(:aggregate_quarterly_target) { FactoryBot.build(:aggregate_quarterly_target) }

  it "must be valid" do
    value(aggregate_quarterly_target).must_be :valid?
  end
end
