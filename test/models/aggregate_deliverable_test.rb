require "test_helper"

describe AggregateDeliverable do
  let(:aggregate_deliverable) { FactoryBot.build(:aggregate_deliverable) }

  it "must be valid" do
    value(aggregate_deliverable).must_be :valid?
  end
end
