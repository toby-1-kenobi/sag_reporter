require "test_helper"

describe DistributionMethod do
  let(:distribution_method) { FactoryBot.build(:distribution_method) }

  it "must be valid" do
    value(distribution_method).must_be :valid?
  end
end
