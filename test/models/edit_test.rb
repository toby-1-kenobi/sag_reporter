require "test_helper"

describe Edit do
  let(:language) { FactoryBot.create(:language) }
  let(:curator) { FactoryBot.create(:user) }
  let(:edit_author) { FactoryBot.create(:user) }
  let(:language_edit) { FactoryBot.build(:edit, record_id: language.id, user: edit_author) }
  let(:pending_edit) { FactoryBot.build(:edit, record_id: language.id, status: Edit.statuses[:pending_single_approval], user: edit_author) }
  let(:double_pending_edit) { FactoryBot.build(:edit, record_id: language.id, status: Edit.statuses[:pending_double_approval], user: edit_author) }
  let(:national_pending_edit) { FactoryBot.build(:edit, record_id: language.id, status: Edit.statuses[:pending_national_approval], user: edit_author) }
  let(:approved_edit) { FactoryBot.build(:edit, record_id: language.id, status: Edit.statuses[:approved], user: edit_author) }
  let(:rejected_edit) { FactoryBot.build(:edit, record_id: language.id, status: Edit.statuses[:rejected], user: edit_author) }

  before do
    Curating.create(user: curator, geo_state: language.geo_states.first)
    edit_author.geo_states << language.geo_states.first
  end

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
    language_edit.user = FactoryBot.build(:user)
    _(language_edit).wont_be :valid?
  end

  it 'must be valid if the user isnt a member of the relevant state(s) but is national' do
    language_edit.user = FactoryBot.build(:user, national: true)
    _(language_edit).must_be :valid?
  end

  it 'has the same geo_states as the language' do
    language_edit.save
    value(language_edit.geo_states).must_equal language.geo_states
  end

  it 'cant be approved if it needs no approval' do
    language_edit.auto_approved!
    _(language_edit).wont_be :approve, curator
  end

  it 'cant be approved if it has already been approved' do
    language_edit.approved!
    _(language_edit).wont_be :approve, curator
  end

  it 'cant be approved if it has been rejected' do
    language_edit.rejected!
    _(language_edit).wont_be :approve, curator
  end

  it 'goes to national level without affecting record when approved on double approval' do
    language_edit.pending_double_approval!
    _(language_edit).must_be :approve, curator
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :pending_national_approval?
    _(language_edit.curated_by).must_equal curator
    language.reload
    _(language.name).must_equal language_edit.old_value
  end

  it 'modifies record when pending single approval and approved' do
    language_edit.pending_single_approval!
    _(language_edit).must_be :approve, curator
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :approved?
    _(language_edit.curated_by).must_equal curator
    language.reload
    _(language.name).must_equal language_edit.new_value
  end

  it 'modifies record when pending national approval and approved' do
    language_edit.pending_national_approval!
    _(language_edit).must_be :approve, curator
    _(language_edit.second_curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :approved?
    language.reload
    _(language.name).must_equal language_edit.new_value
  end

  it 'becomes rejected on approval when the new value is invalid recording error message' do
    language_edit.pending_single_approval!
    language_edit.new_value = ''
    _(language_edit).wont_be :approve, curator
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    _(language_edit).must_be :rejected?
    _(language_edit.curated_by).must_equal curator
    _(language_edit.record_errors).must_be :present?
  end

  it 'can be rejected' do
    language_edit.reject(curator)
    _(language_edit.curation_date).must_be :>, 10.seconds.ago
    language_edit.must_be :rejected?
    _(language_edit.curated_by).must_equal curator
  end

  it 'scopes to pending edits' do
    Edit.find_each do |edit|
      edit.save
    end
    _(Edit.pending).wont_include language_edit
    _(Edit.pending).must_include pending_edit
    _(Edit.pending).must_include double_pending_edit
    _(Edit.pending).wont_include national_pending_edit
    _(Edit.pending).wont_include approved_edit
    _(Edit.pending).wont_include rejected_edit
  end

  it 'scopes to a users curating geo_states' do
    # we need the results of the after_save callback for this test
    # so save all edits.
    Edit.find_each do |edit|
      edit.save
    end
    _(Edit.for_curating(curator)).must_include language_edit
    _(Edit.for_curating(curator)).wont_include double_pending_edit
  end

  it 'must prompt curators when it has been pending for a while' do
    pending_edit.created_at = 8.days.ago
    pending_edit.save
    mail = mock()
    mail.stubs(:deliver_now).returns(true)
    UserMailer.expects(:prompt_curator).with do |user|
      _(user.id).must_equal curator.id
    end.once.returns(mail)
    Edit.prompt_curators
  end

  it 'wont prompt curators who have been recently prompted' do
    UserMailer.expects(:prompt_curator).never
    pending_edit.created_at = 8.days.ago
    pending_edit.save
    curator.curator_prompted = 6.days.ago
    curator.save
    Edit.prompt_curators
  end

  it 'sets the curated prompted date when prompting curators' do
    pending_edit.created_at = 8.days.ago
    pending_edit.save
    User.curating(pending_edit).must_include curator
    Edit.prompt_curators
    Rails.logger.debug "#{curator.email} last_prompted: #{curator.curator_prompted}"
    _(curator.curator_prompted).must_be :>, 10.seconds.ago
  end

end
