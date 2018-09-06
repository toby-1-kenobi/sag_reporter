require "test_helper"

describe Facilitator do
  let(:facilitator) { FactoryBot.build(:facilitator) }

  it "must be valid" do
    value(facilitator).must_be :valid?
  end
end
