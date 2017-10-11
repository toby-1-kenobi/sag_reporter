require 'test_helper'

describe Language do

  let(:language) { Language.new name: 'Test language', lwc: false}
  let(:assam) { GeoState.new name: 'Assam' }
  let(:bihar) { GeoState.new name: 'bihar' }
  let(:national_user) { users(:nathan) }
  let(:state_based_user) { users(:emma) }

  it 'must be valid' do
    value(language).must_be :valid?
  end

  it 'wont be valid with blank locale tag' do
    language.locale_tag = ''
    _(language).wont_be :valid?
  end

  it 'returns its states ids' do
  	language.geo_states << assam
  	language.geo_states << bihar
  	assam.stub(:id, 8) do
  	  bihar.stub(:id, 13) do
  	    value(language.geo_state_ids_str).must_equal '8,13'
  	  end
  	end
  end

  it 'downcases iso' do
    language.iso = 'ABc'
    language.valid?
    _(language.iso).must_equal 'abc'
  end

  it 'sets blank iso to nil' do
    language.iso = ''
    language.valid?
    assert_nil language.iso
  end

  it 'wont be valid with duplicate iso' do
    language.iso = 'abc'
    language2 = language.dup
    language.save
    _(language2).wont_be :valid?
    _(language2.errors[:iso]).must_be :any?
  end

  it 'wont limit scope for national users' do
    _(national_user).must_be :national?
    _(Language.user_limited(national_user).count).must_equal Language.all.count
  end

  it 'will limit scope for state based users' do
    _(state_based_user).wont_be :national?
    #count the languages the user has access to
    language_count = 0
    state_based_user.geo_states.each do |state|
      language_count += state.languages.count
    end
    _(language_count).wont_equal Language.all.count
    _(Language.user_limited(state_based_user).count).must_equal language_count
  end

  it 'has modification date as latest change when there are no edits' do
    _(language.last_changed.to_a).must_equal language.updated_at.to_a
  end

  it 'has latest edit date as latest change if more recent than modification date' do
    language.save
    edit = Edit.create(
            user: users(:andrew),
            model_klass_name: 'Language',
            record_id: language.id,
            attribute_name: 'iso',
            old_value: '',
            new_value: 'abc',
            status: 1,
            created_at: language.updated_at - 1.day
    )
    _(language.last_changed.to_a).must_equal language.updated_at.to_a
    edit.created_at = language.updated_at + 1.day
    edit.save
    _(language.last_changed.to_a).must_equal edit.created_at.to_a
  end
end
