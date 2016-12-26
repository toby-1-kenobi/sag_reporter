require 'test_helper'

describe ProgressMarker do

  let(:progress_marker) { ProgressMarker.new(
      name: 'test pm',
      description: 'Test Progress Marker',
      topic: topics(:movement_building)
  ) }

  it 'must be valid' do
    _(progress_marker).must_be :valid?
  end

  it 'wont be valid without a name' do
    progress_marker.name = ''
    _(progress_marker).wont_be :valid?
  end

  it 'wont be valid with a duplicate name' do
    pm2 = progress_marker.dup
    progress_marker.save
    _(pm2).wont_be :valid?
    _(pm2.errors[:name]).must_be :any?
  end

  it 'wont be valid without a description' do
    progress_marker.description = ''
    _(progress_marker).wont_be :valid?
  end

  it 'wont be valid without an outcome area' do
    progress_marker.topic = nil
    _(progress_marker).wont_be :valid?
  end

  it 'has a status that defaults to active' do
    _(progress_marker.status).must_equal 'active'
  end

  it 'accepts an alternate description' do
    alt_description = 'Alternate description'
    progress_marker.alternate_description = alt_description
    _(progress_marker.alternate_description).must_equal alt_description
  end

end
