require "test_helper"

describe ReportStream do
  let(:report_stream) { FactoryBot.build :report_stream }

  it "must be valid" do
    value(report_stream).must_be :valid?
  end
end
