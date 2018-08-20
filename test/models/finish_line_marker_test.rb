require 'test_helper'

describe FinishLineMarker do
  let(:finish_line_marker) { FactoryBot.build(:finish_line_marker) }

  it 'must be valid' do
    value(finish_line_marker).must_be :valid?
  end
end
