require "test_helper"

describe OutputCount do
  let(:output_count) { OutputCount.new }

  it "must be valid" do
    value(output_count).must_be :valid?
  end
end
