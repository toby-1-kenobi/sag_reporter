require "test_helper"

describe MinistryOutput do
  let(:ministry_output) { FactoryBot.build(:ministry_output) }

  it "must be valid" do
    value(ministry_output).must_be :valid?
  end

  it "wont have a ministry marker not belonging to it's ministry" do
    ministry_output.deliverable = FactoryBot.build(:deliverable)
    value(ministry_output).wont_be :valid?
  end

  it "wont be valid with an invalid year" do
    ministry_output.month = "abcd-08"
    value(ministry_output).wont_be :valid?
    ministry_output.month = "208-08"
    value(ministry_output).wont_be :valid?
    ministry_output.month = "1985-08"
    value(ministry_output).wont_be :valid?
  end

  it "wont be valid with an invalid month" do
    valid_year = Date.today.year
    ministry_output.month = "#{valid_year}-xy"
    value(ministry_output).wont_be :valid?
    ministry_output.month = "#{valid_year}-5"
    value(ministry_output).wont_be :valid?
  end

  it "wont be valid with a year out of range" do
    valid_year = Date.today.year
    ministry_output.month = "2017-08"
    value(ministry_output).wont_be :valid?
    ministry_output.month = "#{valid_year + 51}-08"
    value(ministry_output).wont_be :valid?
  end

  it "wont be valid with a month out of range" do
    valid_year = Date.today.year
    ministry_output.month = "#{valid_year}-00"
    value(ministry_output).wont_be :valid?
    ministry_output.month = "#{valid_year}-13"
    value(ministry_output).wont_be :valid?
  end

end
