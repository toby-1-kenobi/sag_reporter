require "test_helper"

describe ExternalDevice do
  let(:external_device) { ExternalDevice.new user: FactoryBot.create(:user), device_id: '123', name: 'test'}

  it "must be valid" do
    value(external_device).must_be :valid?
  end
end
