require "test_helper"

describe ImpactReport do
  let(:impact_report) { ImpactReport.new report: report }
  let(:report) { Report.new }

  it "can change into a planning report" do
    impact_reports("impact-report-1").make_not_impact
    value(reports("report-1").planning_report).must_be :present?
    value(reports("report-1").impact_report).wont_be :present?
  end

end

