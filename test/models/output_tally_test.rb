require "test_helper"

describe OutputTally do
  let(:output_tally) { OutputTally.new }

  it "must be valid" do
    value(output_tally).must_be :valid?
  end
end
