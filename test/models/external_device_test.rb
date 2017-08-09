require "test_helper"

describe ExternalDevice do
  let(:external_device) { ExternalDevice.new }

  it "must be valid" do
    value(external_device).must_be :valid?
  end
end
