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

  it 'represents as a string with year and source' do
    _(population.to_s).must_equal '1,600 (2015 ethnologue)'
  end

  it 'represents as a string with source' do
    population.year = nil
    _(population.to_s).must_equal '1,600 (ethnologue)'
  end

  it 'represents as a string with year' do
    population.source = nil
    _(population.to_s).must_equal '1,600 (2015)'
  end

  it 'represents as a string with neither year nor source' do
    population.year = nil
    population.source = nil
    _(population.to_s).must_equal '1,600'
  end

end
