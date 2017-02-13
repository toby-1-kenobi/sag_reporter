require 'test_helper'

describe OrganisationEngagement do
  let(:language) { Language.new name: 'test language' }
  let(:org) { Organisation.new name: 'test org' }
  let(:organisation_engagement) { OrganisationEngagement.new language: language, organisation: org }

  it 'must be valid' do
    value(organisation_engagement).must_be :valid?
  end
end
