require "test_helper"

describe ImpactReport do
  let(:impact_report) { ImpactReport.new geo_state: geo_states(:nb),
      report_date: Date.today,
      content: "test report",
      state: :active }

  it "must be valid" do
    value(impact_report).must_be :valid?
  end
end
