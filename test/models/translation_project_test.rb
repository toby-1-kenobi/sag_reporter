require "test_helper"

describe TranslationProject do

  let(:translation_project) { FactoryBot.build(:translation_project) }

  it "must be valid" do
    value(translation_project).must_be :valid?
  end

  it "wont be valid without unique name-language" do
    tp2 = translation_project.dup
    translation_project.save
    _(tp2).wont_be :valid?
  end

end
