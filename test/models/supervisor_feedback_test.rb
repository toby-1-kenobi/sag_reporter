require "test_helper"

describe SupervisorFeedback do
  let(:supervisor_feedback) { FactoryBot.build(:supervisor_feedback)}

  it "must be valid" do
    value(supervisor_feedback).must_be :valid?
  end
end
