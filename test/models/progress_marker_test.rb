require "test_helper"

describe ProgressMarker do
  let(:progress_marker) { ProgressMarker.new }

  it "must be valid" do
    value(progress_marker).must_be :valid?
  end
end
