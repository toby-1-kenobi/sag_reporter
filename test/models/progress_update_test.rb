require "test_helper"

describe ProgressUpdate do
  let(:progress_update) { ProgressUpdate.new }

  it "must be valid" do
    value(progress_update).must_be :valid?
  end
end
