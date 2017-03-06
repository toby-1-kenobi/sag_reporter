require 'test_helper'

describe Organisation do
  let(:organisation) { Organisation.new name: 'test org' }

  it 'must be valid' do
    value(organisation).must_be :valid?
  end
end
