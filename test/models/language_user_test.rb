require "test_helper"

describe LanguageUser do
  let(:language_user) { FactoryBot.build(:language_user) }

  it "must be valid" do
    value(language_user).must_be :valid?
  end
end
