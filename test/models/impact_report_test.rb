require "test_helper"

describe ImpactReport do
  let(:impact_report) { ImpactReport.new }

  it "must be valid" do
    value(impact_report).must_be :valid?
  end
end
