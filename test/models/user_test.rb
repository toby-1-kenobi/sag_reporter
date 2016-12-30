require 'test_helper'

describe User do

  let(:user) { User.new(
    name: 'Example User',
    phone: '9876543210',
    password: 'foobar',
    password_confirmation: 'foobar',
    role: Role.take,
    mother_tongue: Language.take
  ) }
  let(:zone_with_alt_pms) { Zone.new(name: 'test zone', pm_description_type: :alternate) }
  let(:state_in_alt_zone) { GeoState.new(
      name: 'test state',
      zone: zone_with_alt_pms
  ) }

  before do
    user.geo_states << geo_states(:nb)
  end
\

  it 'must be valid' do
    value(user).must_be :valid?
  end
  
  it 'can have multiple geo_states' do
    user.geo_states << geo_states(:assam)
    value(user.geo_states.length).must_be :>, 1
  end

  it 'wont be destroyed with report' do
    report = Report.new(
        reporter: user,
        content: 'hi',
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
        participant_amount: 0,
        record_creator: user
    )
    event.save!
    user.destroy
    value(user).must_be :persisted?
  end

  it 'wont be destroyed with person' do
    person = Person.new(name: 'joe', record_creator: user)
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

  it 'wont be destroyed with output count' do
    oc = output_counts(:output_count_1)
    oc.user = user
    oc.save!
    user.destroy
    value(user).must_be :persisted?
  end

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

  it 'wont be valid with a blank phone number' do
    user.phone = '     '
    value(user).wont_be :valid?
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
    _(user).must_be :use_alternate_pm_descriptions?
  end

  it 'doesnt specify alternate pm descriptions if it is not in a zone that requires them' do
    user.zones.each{ |zone| zone.pm_description_type = 'default' }
    _(user).wont_be :use_alternate_pm_descriptions?
  end

  it 'knows it responds to can_...? and is_a_...? methods' do
    _(user).must_respond_to :is_a_bird?
    _(user).must_respond_to :can_fly?
    _(user).wont_respond_to :this_is_not_a_real_method
  end

end
