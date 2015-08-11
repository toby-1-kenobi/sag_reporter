require "test_helper"

describe ActionPoint do
  let(:action_point) { ActionPoint.new }

  it "must be valid" do
    value(action_point).must_be :valid?
  end
end
