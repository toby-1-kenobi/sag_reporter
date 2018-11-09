require 'test_helper'

describe User do

  let(:user) { FactoryBot.create(:user,
                                 national: true,
                                 trusted: true,
                                 email_confirmed: true) }
  let(:national_user) { FactoryBot.create(:user, national: true) }
  let(:zone_with_alt_pms) { Zone.new(name: 'test zone', pm_description_type: :alternate) }
  let(:state_in_alt_zone) { GeoState.new(
      name: 'test state',
      zone: zone_with_alt_pms
  ) }
  let(:pirate_language) { FactoryBot.build(:language, locale_tag: 'pirate') }
  let(:assam) { FactoryBot.create(:geo_state, name: 'Assam') }
  let(:nb) { FactoryBot.create(:geo_state, name: 'North Bengal') }

  before do
    user.geo_states << FactoryBot.build(:geo_state)
    FactoryBot.create(:language, name: 'English', locale_tag: 'en')
  end


  it 'must be valid' do
    user.valid?
    puts user.errors.full_messages
    value(user).must_be :valid?
  end

  it 'wont be valid without trusted set' do
    user.trusted = nil
    _(user).wont_be :valid?
  end

  it 'wont be valid without national set' do
    user.national = nil
    _(user).wont_be :valid?
  end

  it 'wont be valid without admin set' do
    user.admin = nil
    _(user).wont_be :valid?
  end

  it 'wont be valid without national curator set' do
    user.national_curator = nil
    _(user).wont_be :valid?
  end
  
  it 'can have multiple geo_states' do
    user.geo_states << assam
    value(user.geo_states.length).must_be :>, 1
  end

  it 'wont be destroyed with report' do
    FactoryBot.create( :report, reporter: user)
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with event' do
    event = Event.new(
        event_label: 'hi',
        event_date: Time.now,
        geo_state: FactoryBot.build(:geo_state),
        participant_amount: 0,
        record_creator: user
    )
    event.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with person' do
    person = Person.new(name: 'jpu = oe', record_creator: user, geo_state: FactoryBot.build(:geo_state))
    person.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with progress update' do
    FactoryBot.create(:progress_update, user: user)
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be valid with a blank name' do
    user.name = '     '
    value(user).wont_be :valid?
  end

  it 'wont be valid with a blank phone number and email' do
    user.phone = '     '
    user.email = '   '
    value(user).wont_be :valid?
  end

  it 'can have no phone if email is present' do
    user.phone = nil
    user.email = 'me@example.com'
    _(user).must_be :valid?
  end

  it 'wont be valid with a long name' do
    user.name = 'a' * 51
    value(user).wont_be :valid?
  end

  # In India mobile phone numbers are 10 digits
  it "wont be valid with a phone number that's not 10 digits long" do
    user.phone = '1' * 11
    value(user).wont_be :valid?
    user.phone = '1' * 9
    value(user).wont_be :valid?
  end

  it "wont be valid with a phone number that's not all digits" do
    user.phone = 'a' * 10
    value(user).wont_be :valid?
    user.phone = '+123456789'
    value(user).wont_be :valid?
    user.phone = '1234 56789'
    value(user).wont_be :valid?
  end

  it "must be valid with a phone number that's got a valid prefix" do
    user.phone = '+91 0123-456-789'
    value(user).must_be :valid?
    user.phone = '01234 567890'
    value(user).must_be :valid?
    user.phone = '91 0123-4-789'
    value(user).must_be :valid?
    user.phone = '0012 347 895'
    value(user).must_be :valid?
  end

  it 'wont be valid with a duplicate phone number' do
    duplicate_user = user.dup
    user.save
    value(duplicate_user).wont_be :valid?
  end

  it 'wont be valid with a blank password' do
    user.password = user.password_confirmation = ' ' * 6
    value(user).wont_be :valid?
  end

  it 'wont be valid with a too short password' do
    user.password = user.password_confirmation = 'a' * 5
    value(user).wont_be :valid?
  end
  
  test 'authenticated? should return false for a user with nil digest' do
    assert_not user.authenticated?('')
  end

  it 'specifies alternate pm descriptions if it is in a zone that requires them' do
    user.geo_states << state_in_alt_zone
    _(user).must_be :sees_alternate_pm_descriptions?
  end

  it 'will unconfirm email and send confirmation on email change' do
    mock_mailer = mock
    mock_mailer.expects(:deliver_now).at_least_once
    UserMailer.stubs(:user_email_confirmation).returns(mock_mailer)
    _(user).must_be :save
    user.update_column(:email_confirmed, true)
    user.email = 'another_me@example.com'
    user.save
    _(user).wont_be :email_confirmed?
  end

  it 'has a locale with default "en"' do
    _(user.locale).must_equal 'en'
    user.interface_language = pirate_language
    _(user.locale).must_equal 'pirate'
  end

  it 'is not valid with an interface language that has no locale tag' do
    interface_language = Language.new
    user.interface_language = interface_language
    _(user).wont_be :valid?
    interface_language.locale_tag = 'ha'
    _(user).must_be :valid?
  end

  it 'scopes to curators for an edit' do
    curators = FactoryBot.create_list(:user_with_curatings, 2)
    first_s_language = FactoryBot.create(:state_language, geo_state: curators.first.curated_states.first)
    second_s_language = FactoryBot.create(:state_language, geo_state: curators.second.curated_states.first)
    first_language_edit = FactoryBot.create(:edit, user: user, record_id: first_s_language.language_id)
    second_language_edit = FactoryBot.create(:edit, user: user, record_id: second_s_language.language_id)
    _(User.curating(first_language_edit)).must_include curators.first
    _(User.curating(first_language_edit)).wont_include curators.second
    _(User.curating(second_language_edit)).must_include curators.second
    _(User.curating(second_language_edit)).wont_include curators.first
  end

  it 'scopes to zones' do
    zone_a = Zone.new(name: 'A')
    zone_b = Zone.new(name: 'B')
    zone_c = Zone.new(name: 'C')
    state_a = FactoryBot.create(:geo_state, zone: zone_a)
    state_b = FactoryBot.create(:geo_state, zone: zone_b)
    state_c = FactoryBot.create(:geo_state, zone: zone_c)
    user_a = FactoryBot.create(:user)
    user_a.geo_states << state_a
    user_bc = FactoryBot.create(:user)
    user_bc.geo_states << [state_b, state_c]
    user_c = FactoryBot.create(:user)
    user_c.geo_states << state_c
    users_in_ab = User.in_zones([zone_a, zone_b])
    _(users_in_ab).must_include user_a
    _(users_in_ab).must_include user_bc
    _(users_in_ab).wont_include user_c
  end

  it 'scopes to a user' do
    state_a = FactoryBot.create(:geo_state)
    state_b = FactoryBot.create(:geo_state)
    user_a = FactoryBot.create(:user)
    user_a.geo_states << state_a
    user_a_rego = FactoryBot.create(:user, registration_status: 1) #zone approved, but not registered
    user_a_rego.geo_states << state_a
    user_b = FactoryBot.create(:user)
    user_b.geo_states << state_b
    user_ab = FactoryBot.create(:user)
    user_ab.geo_states << [state_a, state_b]
    users = User.visible_to(user_a)
    _(users).must_include user_ab
    _(users).wont_include user_b
    _(users).wont_include user_a_rego
    more_users = User.visible_to(national_user)
    _(more_users).must_include user_b
    _(more_users).wont_include user_a_rego
  end

  it 'knows if it curates for a language' do
    user.curated_states.clear
    lang = FactoryBot.create(:language)
    _(user.curates_for?(lang)).wont_equal true
    user.curated_states << lang.geo_states.first
    user.save
    _(user.curates_for? lang).must_equal true
  end

  it 'goes through the whole registration approval process' do
    zone_a = Zone.new(name: 'A')
    zone_b = Zone.new(name: 'B')
    zone_c = Zone.new(name: 'C')
    state_a = FactoryBot.create(:geo_state, zone: zone_a)
    state_a1 = FactoryBot.create(:geo_state, zone: zone_a)
    state_b = FactoryBot.create(:geo_state, zone: zone_b)
    state_c = FactoryBot.create(:geo_state, zone: zone_c)
    registering_user = FactoryBot.create(:user, registration_status: :unapproved)
    registering_user.geo_states.clear
    registering_user.geo_states << [state_a, state_b, state_c]
    approver_ab = FactoryBot.create(:user, zone_admin: true)
    approver_ab.geo_states << [state_a1, state_b]
    _(approver_ab).must_be :persisted?
    approver_c = FactoryBot.create(:user, zone_admin: true)
    approver_c.geo_states << [state_c]
    _(approver_c).must_be :persisted?
    final_approver = FactoryBot.create(:user, lci_board_member: true)
    registering_user.registration_approval_step(approver_ab)
    Rails.logger.debug("all approvals: #{RegistrationApproval.all.inspect}")
    _(registering_user).must_be :unapproved?
    registering_user.registration_approval_step(approver_c)
    Rails.logger.debug("all approvals: #{RegistrationApproval.all.inspect}")
    _(registering_user).must_be :zone_approved?
    registering_user.registration_approval_step(final_approver)
    _(registering_user).must_be :approved?
  end

  it 'gets approved directly on lci_board_member approval' do
    zone_a = Zone.new(name: 'A')
    state_a = FactoryBot.create(:geo_state, zone: zone_a)
    registering_user = FactoryBot.create(:user, registration_status: :unapproved)
    registering_user.geo_states.clear
    registering_user.geo_states << [state_a]
    approver = FactoryBot.create(:user, zone_admin: true, lci_board_member: true)
    approver.geo_states << [state_a]
    registering_user.registration_approval_step(approver)
    _(registering_user).must_be :approved?
  end

  it 'must update timestamp when a geo_state is added' do
    init_value = user.updated_at
    user.geo_states << FactoryBot.create(:geo_state)
    user.reload
    _(user.updated_at).must_be :>, init_value
  end

  it 'must update timestamp when a geo_state is removed' do
    state = FactoryBot.create(:geo_state)
    user.geo_states << state
    user.reload
    init_value = user.updated_at
    user.geo_states.delete state
    user.reload
    _(user.updated_at).must_be :>, init_value
  end

end
