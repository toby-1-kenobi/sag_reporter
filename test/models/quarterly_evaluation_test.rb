require "test_helper"

describe QuarterlyEvaluation do
  let(:quarterly_evaluation) { FactoryBot.build(:quarterly_evaluation) }

  it "must be valid" do
    value(quarterly_evaluation).must_be :valid?
  end
end
