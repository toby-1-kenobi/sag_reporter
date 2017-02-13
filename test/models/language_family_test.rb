require 'test_helper'

describe LanguageFamily do
  let(:language_family) { LanguageFamily.new name: 'test family' }

  it 'must be valid' do
    value(language_family).must_be :valid?
  end
end
