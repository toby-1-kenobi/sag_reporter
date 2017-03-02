require 'test_helper'

describe DataSource do

  let(:data_source) { DataSource.new name: 'my data source'}

  it 'must be valid' do
    value(data_source).must_be :valid?
  end

  it 'wont be valid without a name' do
    data_source.name = ''
    value(data_source).wont_be :valid?
  end

end
