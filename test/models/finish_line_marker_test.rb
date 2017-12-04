require 'test_helper'

describe FinishLineMarker do
  let(:finish_line_marker) { finish_line_markers(:flm_01)}

  it 'must be valid' do
    value(finish_line_marker).must_be :valid?
  end
end
