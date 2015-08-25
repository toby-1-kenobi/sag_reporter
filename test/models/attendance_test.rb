require "test_helper"

describe Attendance do
  let(:attendance) { Attendance.new }

  it "must be valid" do
    value(attendance).must_be :valid?
  end
end
