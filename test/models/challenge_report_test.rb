require "test_helper"

describe ChallengeReport do
  let(:challenge_report) { ChallengeReport.new }

  it "must be valid" do
    value(challenge_report).must_be :valid?
  end
end
