require "test_helper"

describe TranslationDistribution do
  let(:translation_distribution) { FactoryBot.build(:translation_distribution)}

  it "must be valid" do
    value(translation_distribution).must_be :valid?
  end
end
