require "test_helper"

describe ImpactReport do

  it "can change into a planning report" do
    impact_report = FactoryBot.create(:impact_report)
    report = impact_report.report
    impact_report.make_not_impact
    value(report.planning_report).must_be :present?
    value(report.impact_report).wont_be :present?
  end

end

