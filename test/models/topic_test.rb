require 'test_helper'

describe Topic do

  let(:topic) { Topic.new(name: 'test topic', number: 6) }

  let(:pm_weight_2) { ProgressMarker.new(
      weight: 2,
      name: 'pm_weight_2'
  ) }
  let(:pm_weight_3) { ProgressMarker.new(
      weight: 3,
      name: 'pm_weight_3'
  ) }
  let(:pm_weight_2_deprecated) { ProgressMarker.new(
      weight: 2,
      name: 'pm_weight_2_deprecated',
      status: 'deprecated'
  ) }

  it 'must have a name' do
    topic.name = ''
    _(topic).wont_be :valid?
  end

  it 'must have a number' do
    topic.number = nil
    _(topic).wont_be :valid?
  end

  it 'gives the maximum possible score for its active progress markers' do
    max_spreadness_score = ProgressMarker.spread_text.keys.max
    topic.progress_markers << pm_weight_2
    topic.progress_markers << pm_weight_3
    topic.progress_markers << pm_weight_2_deprecated
    topic.save
    _(topic.progress_markers.count).must_equal 3
    _(topic.max_outcome_score).must_equal max_spreadness_score * (2 + 3)
  end
end
