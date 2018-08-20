require "test_helper"

describe MtResource do
  let(:mt_resource) { MtResource.new geo_state: FactoryBot.build(:geo_state) }

  it "must be valid" do
    value(mt_resource).must_be :valid?
  end
end
