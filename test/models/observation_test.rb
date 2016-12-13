require "test_helper"

describe Observation do
  let(:observation) { Observation.new report: reports("report-1"), person: people("user-1") }

  it "must be valid" do
    value(observation).must_be :valid?
  end
end
