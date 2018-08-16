require 'test_helper'

describe User do

  let(:user) { User.new(
    name: 'Example User',
    phone: '9876543210',
    password: 'foobar',
    password_confirmation: 'foobar',
    email: 'me@example.com',
    email_confirmed: true,
    trusted: true,
    national: true,
    admin: false,
    national_curator: false
  ) }
  let(:zone_with_alt_pms) { Zone.new(name: 'test zone', pm_description_type: :alternate) }
  let(:state_in_alt_zone) { GeoState.new(
      name: 'test state',
      zone: zone_with_alt_pms
  ) }
  let(:pirate_language) { Language.new(locale_tag: 'pirate') }
  let(:user_curating_assam) { users(:andrew) }
  let(:user_curating_nb) { users(:nathan) }
  let(:assam_edit) { edits(:pending_single) }
  let(:nb_edit) { edits(:pending_double) }

  before do
    user.geo_states << geo_states(:nb)
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
    user.geo_states << geo_states(:assam)
    value(user.geo_states.length).must_be :>, 1
  end

  it 'wont be destroyed with report' do
    report = Report.new(
        reporter: user,
        content: 'hi',
        geo_state: geo_states(:nb),
        impact_report: impact_reports(:'impact-report-1')
    )
    report.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with event' do
    event = Event.new(
        event_label: 'hi',
        event_date: Time.now,
        geo_state: geo_states(:nb),
        participant_amount: 0,
        record_creator: user
    )
    event.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with person' do
    person = Person.new(name: 'joe', record_creator: user, geo_state: geo_states(:nb))
    person.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with progress update' do
    pu = ProgressUpdate.new(
        progress: 1,
        month: 1,
        year: 2016,
        user: user,
        language_progress: language_progresses(:aka_skills_used)
    )
    pu.save!
    user.destroy
    value(user).must_be :persisted?
  end

  # it 'wont be destroyed with output count' do
  #   oc = output_counts(:output_count_1)
  #   oc.user = user
  #   oc.save!
  #   user.destroy
  #   value(user).must_be :persisted?
  # end

  it 'wont be destroyed with mt resource' do
    resource = mt_resources(:'resource-1')
    resource.user = user
    resource.save!
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

  it "doesn't specify alternate pm descriptions if it is not in a zone that requires them" do
    user.zones.each{ |zone| zone.pm_description_type = 'default' }
    _(user).wont_be :sees_alternate_pm_descriptions?
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
    # callbacks are skipped when fixtures are inserted
    # we need the results of the after_save callback on Edit for this test
    # so save the edits.
    assam_edit.save
    nb_edit.save
    _(User.curating(assam_edit)).must_include user_curating_assam
    _(User.curating(assam_edit)).wont_include user_curating_nb
    _(User.curating(nb_edit)).must_include user_curating_nb
    _(User.curating(nb_edit)).wont_include user_curating_assam
  end

  it 'knows if it curates for a language' do
    user.curated_states.clear
    _(user.curates_for? languages(:toto)).wont_equal true
    user.curated_states << languages(:toto).geo_states.first
    user.save
    _(user.curates_for? languages(:toto)).must_equal true
  end

end
