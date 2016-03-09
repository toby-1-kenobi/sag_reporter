require "test_helper"

describe ImpactReport do
  let(:impact_report) { ImpactReport.new report: report }
  let(:report) { Report.new }

  it "can change into a planning report" do
    impact_reports(:test_impact_report).make_not_impact
    value(reports(:test_report).planning_report).must_be :present?
    value(reports(:test_report).impact_report).wont_be :present?
  end

end
