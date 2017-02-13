require 'test_helper'

describe ProgressMarker do

  let(:progress_marker) { ProgressMarker.new(
      name: 'test pm',
      topic: topics(:movement_building)
  ) }
  let(:zone_with_default_pms) { Zone.new(name: 'test zone 1') }
  let(:state_in_default_zone) { GeoState.new(
      name: 'test state 1',
      zone: zone_with_default_pms
  ) }
  let(:zone_with_alt_pms) { Zone.new(name: 'test zone 2', pm_description_type: :alternate) }
  let(:state_in_alt_zone) { GeoState.new(
      name: 'test state 2',
      zone: zone_with_alt_pms
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

  it 'wont be valid with a duplicate number' do
    progress_marker.number = 5
    pm2 = progress_marker.dup
    progress_marker.save
    _(pm2).wont_be :valid?
    _(pm2.errors[:number]).must_be :any?
  end

  it 'wont be valid without an outcome area' do
    progress_marker.topic = nil
    _(progress_marker).wont_be :valid?
  end

  it 'has a status that defaults to active' do
    _(progress_marker).must_be :active?
  end

  it 'accepts an alternate description' do
    alt_description = 'Alternate description'
    progress_marker.alternate_description = alt_description
    _(progress_marker.alternate_description).must_equal alt_description
  end

  it 'finds or creates LanguageProgresses as necessary' do
    state_language = state_languages(:arunachal_pradesh_galo)
    init_language_progress_count = LanguageProgress.count
    # the first call should create a new LanguageProgress and increase the count
    language_progress = progress_marker.language_progress(state_language)
    lp_count_after_first_call = LanguageProgress.count
    _(lp_count_after_first_call).must_equal init_language_progress_count + 1
    # the second call shouldn't create a new LanguageProgress since it's now already there
    language_progress = progress_marker.language_progress(state_language)
    _(LanguageProgress.count).must_equal lp_count_after_first_call
  end

  it 'groups active progress markers by outcome area then weight' do
    pms = ProgressMarker.by_outcome_area_and_weight
    _(pms.count).must_equal Topic.count
    total_count = 0
    pms.values.each do |by_topic|
      by_topic.values.each do |by_weight|
        total_count += by_weight.count
      end
    end
    _(total_count).must_equal ProgressMarker.active.count
  end

  # it 'gives the appropriate description to the user' do
  #   default_user = users(:andrew)
  #   default_user.geo_states.clear
  #   default_user.geo_states << state_in_default_zone
  #   special_user = users(:emma)
  #   special_user.geo_states.clear
  #   special_user.geo_states << state_in_alt_zone
  #   # no alternate description, both users see normal description
  #   _(progress_marker.description_for(default_user)).must_equal progress_marker.description
  #   _(progress_marker.description_for(special_user)).must_equal progress_marker.description
  #   # with alternate description, special users see alt description
  #   progress_marker.alternate_description = 'my alternate description'
  #   _(progress_marker.description_for(default_user)).must_equal progress_marker.description
  #   _(progress_marker.description_for(special_user)).must_equal progress_marker.alternate_description
  # end

  it 'has a translation key based on its number' do
    progress_marker.number = 5
    _(progress_marker.translation_key).must_equal 'pm_05'
    progress_marker.number = 23
    _(progress_marker.translation_key).must_equal 'pm_23'
  end

end
