require 'test_helper'

describe OrganisationTranslation do
  let(:language) { Language.new name: 'test language' }
  let(:org) { Organisation.new name: 'test org' }
  let(:organisation_translation) { OrganisationTranslation.new language: language, organisation: org }

  it 'must be valid' do
    value(organisation_translation).must_be :valid?
  end
end
