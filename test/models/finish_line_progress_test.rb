require "test_helper"

describe FinishLineProgress do
  let(:finish_line_progress) { FinishLineProgress.new status: 0}

  it "must be valid" do
    value(finish_line_progress).must_be :valid?
  end

  it "wont be valid without status" do
    finish_line_progress.status = nil
    value(finish_line_progress).wont_be :valid?
  end

end
