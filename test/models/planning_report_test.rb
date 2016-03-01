require "test_helper"

describe PlanningReport do
  let(:planning_report) { PlanningReport.new }

  it "must be valid" do
    value(planning_report).must_be :valid?
  end
end
