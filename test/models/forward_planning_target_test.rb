require "test_helper"

describe ForwardPlanningTarget do
  let(:forward_planning_target) { ForwardPlanningTarget.new }

  it "must be valid" do
    value(forward_planning_target).must_be :valid?
  end
end
