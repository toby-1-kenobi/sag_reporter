require "test_helper"

describe Edit do
  let(:language) { languages(:assamese) }
  let(:admin_user) { users(:andrew) }
  let(:language_edit) { edits(:language_edit) }

  it 'must be valid' do
    value(language_edit).must_be :valid?
  end

  it 'wont be valid with a non-existent record id' do
    language_edit.record_id = -1
    _(language_edit).wont_be :valid?
    _(language_edit.errors[:record_id]).must_be :present?
  end

  it 'wont be valid if the value isnt changed' do
    language_edit.new_value = language_edit.old_value
    _(language_edit).wont_be :valid?
  end

  it 'wont be valid if the user isnt a member of the relevant state(s) or national' do
    language_edit.user = users(:peter)
    _(language_edit).wont_be :valid?
  end

  it 'must be valid if the user isnt a member of the relevant state(s) but is national' do
    language_edit.user = users(:richard)
    _(language_edit).must_be :valid?
  end

  it 'has the same geo_states as the language' do
    language_edit.save
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
    _(language_edit.curated_by).must_equal admin_user
    _(language_edit.record_errors).must_be :present?
  end

  it 'can be rejected' do
    language_edit.reject(admin_user)
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    language_edit.must_be :rejected?
    _(language_edit.curated_by).must_equal admin_user
  end

  it 'scopes to pending edits' do
    _(Edit.pending).wont_include language_edit
    _(Edit.pending).must_include edits(:pending_single)
    _(Edit.pending).must_include edits(:pending_double)
    _(Edit.pending).wont_include edits(:pending_national)
    _(Edit.pending).wont_include edits(:approved)
    _(Edit.pending).wont_include edits(:rejected)
  end

  it 'scopes to a users curating geo_states' do
    # callbacks are skipped when fixtures are inserted
    # we need the results of the after_save callback for this test
    # so save all edits.
    Edit.find_each do |edit|
      edit.save
    end
    _(Edit.for_curating(admin_user)).must_include language_edit
    _(Edit.for_curating(admin_user)).wont_include edits(:pending_double)
  end

end
