require "test_helper"

describe LanguageName do
  let(:language_name) { LanguageName.new name: 'test', language: languages(:toto)}

  it "must be valid" do
    value(language_name).must_be :valid?
  end

  it "wont be valid without a name" do
    language_name.name = ''
    value(language_name).wont_be :valid?
  end

  it "wont be valid without a language" do
    language_name.language = nil
    value(language_name).wont_be :valid?
  end

end
