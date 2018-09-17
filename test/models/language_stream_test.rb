require "test_helper"

describe LanguageStream do
  let(:language_stream) { FactoryBot.build(:language_stream) }

  it "must be valid" do
    value(language_stream).must_be :valid?
  end
end
