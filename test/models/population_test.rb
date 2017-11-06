require 'test_helper'

describe Population do

  let(:population) { populations(:toto2015) }

  it 'must be valid' do
    _(population).must_be :valid?
  end

  it 'wont be valid with no amount' do
    population.amount = nil
    _(population).wont_be :valid?
  end

  it 'wont be valid with no language' do
    population.language = nil
    _(population).wont_be :valid?
  end

end
