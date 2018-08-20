require 'test_helper'

describe Curating do
  let(:curating) { Curating.new(geo_state: FactoryBot.build(:geo_state), user: FactoryBot.create(:user)) }

  it 'must be valid' do
    value(curating).must_be :valid?
  end

  it 'wont be valid without a user' do
    curating.user = nil
    value(curating).wont_be :valid?
  end

  it 'wont be valid without a geo_state' do
    curating.geo_state = nil
    value(curating).wont_be :valid?
  end

  it 'wont be valid if the user-geo_state combo already exists' do
    curating_dup = curating.dup
    curating.save
    value(curating_dup).wont_be :valid?
  end

end
