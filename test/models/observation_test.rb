require "test_helper"

describe Observation do
  let(:observation) { Observation.new }

  it "must be valid" do
    value(observation).must_be :valid?
  end
end
