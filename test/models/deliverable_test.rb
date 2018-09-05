require 'test_helper'

describe Deliverable do

  let(:deliverable) { FactoryBot.build(:deliverable) }

  it "must be valid" do
    value(deliverable).must_be :valid?
  end

end

