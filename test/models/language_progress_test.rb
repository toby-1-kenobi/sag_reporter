require "test_helper"

describe LanguageProgress do
  let(:language_progress) { LanguageProgress.new }

  it "must be valid" do
    value(language_progress).must_be :valid?
  end
end
