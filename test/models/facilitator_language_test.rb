require "test_helper"

describe FacilitatorLanguage do
  let(:facilitator_language) { FactoryBot.build(:facilitator_language) }

  it "must be valid" do
    value(facilitator_language).must_be :valid?
  end
end
