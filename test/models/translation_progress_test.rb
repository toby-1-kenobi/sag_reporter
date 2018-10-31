require "test_helper"

describe TranslationProgress do

  let(:translation_progress) { FactoryBot.build(:translation_progress) }

  it "must be valid" do
    value(translation_progress).must_be :valid?
  end

  it "can't be duplicated" do
    translation_progress.save
    tp2 = translation_progress.dup
    _(tp2).wont_be :valid?
  end

end
