require "test_helper"

describe Purpose do
  let(:purpose) { Purpose.new }

  it "must be valid" do
    value(purpose).must_be :valid?
  end
end
