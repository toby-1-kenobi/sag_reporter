require 'test_helper'

describe Zone do

  let(:zone) { Zone.new(
      name: 'test zone'
  ) }

  it 'must be valid' do
    _(zone).must_be :valid?
  end

  it "must have pm description type option that defaults to 'default'" do
    _(zone.pm_description_type).must_equal 'default'
  end

end