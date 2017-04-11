require "test_helper"

describe Edit do
  let(:language) { languages(:assamese) }
  let(:admin_user) { users(:andrew) }
  let(:language_edit) { Edit.new(
      user: admin_user,
      model_klass_name: 'Language',
      record_id: language.id,
      attribute_name: 'name',
      old_value: language.name,
      new_value: 'new name'
  ) }

  it 'must be valid' do
    value(language_edit).must_be :valid?
  end

  it 'wont be valid with a non-existent record id' do
    language_edit.record_id = -1
    _(language_edit).wont_be :valid?
    _(language_edit.errors[:record_id]).must_be :present?
  end

  it 'has the same geo_states as the language' do
    value(language_edit.geo_states).must_equal language.geo_states
  end

  it 'cant be approved if it needs no approval' do
    language_edit.auto_approved!
    _(language_edit).wont_be :approve, admin_user
  end

  it 'cant be approved if it has already been approved' do
    language_edit.approved!
    _(language_edit).wont_be :approve, admin_user
  end

  it 'cant be approved if it has been rejected' do
    language_edit.rejected!
    _(language_edit).wont_be :approve, admin_user
  end

  it 'goes to national level without affecting record when approved on double approval' do
    language_edit.pending_double_approval!
    _(language_edit).must_be :approve, admin_user
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :pending_national_approval?
    _(language_edit.curated_by).must_equal admin_user
    language.reload
    _(language.name).must_equal language_edit.old_value
  end

  it 'modifies record when pending single approval and approved' do
    language_edit.pending_single_approval!
    _(language_edit).must_be :approve, admin_user
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :approved?
    _(language_edit.curated_by).must_equal admin_user
    language.reload
    _(language.name).must_equal language_edit.new_value
  end

  it 'modifies record when pending national approval and approved' do
    language_edit.pending_national_approval!
    _(language_edit).must_be :approve, admin_user
    _(language_edit.second_curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :approved?
    language.reload
    _(language.name).must_equal language_edit.new_value
  end

  it 'becomes rejected on approval when the new value is invalid recording error message' do
    language_edit.pending_single_approval!
    language_edit.new_value = ''
    _(language_edit).wont_be :approve, admin_user
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :rejected?
    _(language_edit.record_errors).must_be :present?
  end

end
