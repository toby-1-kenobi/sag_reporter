require "test_helper"

describe FacilitatorFeedback do
  let(:facilitator_feedback) { FactoryBot.build(:facilitator_feedback) }

  it "must be valid" do
    value(facilitator_feedback).must_be :valid?
  end
end
