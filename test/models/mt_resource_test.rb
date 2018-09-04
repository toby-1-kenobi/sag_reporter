require "test_helper"

describe MtResource do
  let(:mt_resource) { FactoryBot.build(:mt_resource) }

  it "must be valid" do
    mt_resource.valid?
    Rails.logger.debug(mt_resource.errors.full_messages)
    value(mt_resource).must_be :valid?
  end
end
