require "test_helper"

describe Observation do
  let(:report) { Report.new }
  let(:person) { Person.new name: "Dude" }
  let(:observation) { Observation.new report: report, person: person }

  it "must be valid" do
    value(observation).must_be :valid?
  end
end
