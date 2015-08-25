require "test_helper"

describe Translation do
  let(:translation) { Translation.new }

  it "must be valid" do
    value(translation).must_be :valid?
  end
end
