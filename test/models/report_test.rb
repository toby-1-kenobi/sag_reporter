require 'test_helper'

describe Report do

  let(:geo_state) { FactoryBot.create(:geo_state) }
  let(:report) { Report.new(
    content: 'report content',
    reporter: FactoryBot.build(:user),
    geo_state: geo_state,
    status: :active,
    report_date: Date.today,
    sub_district: sub_district,
    location: 'some place'
  ) }
  let(:impact_report) { ImpactReport.new }
  let(:sub_district) { SubDistrict.new district: district}
  let(:district) { District.new geo_state: geo_state }

  before do
    report.impact_report = impact_report
  end

  it 'is valid with content and reporter' do
  	_(report).must_be :valid?
  end

  it 'is not valid without content' do
  	report.content = ''
  	report.valid?
    value(report.errors[:content]).must_be :any?
  end

  it 'is not valid without reporter' do
  	report.reporter = nil
    report.valid?
    value(report.errors[:reporter]).must_be :any?
  end

  it 'may have many languages' do
  	report.languages << FactoryBot.build_list(:language, 2)
  	_(report.languages.length).must_equal 2
  end

  it 'may have many topics' do
    report.topics << FactoryBot.build_list(:topic, 2)
  	_(report.topics.length).must_equal 2
  end

  it 'may have content in various scripts' do
  	report.content = 'বাংলা'
  	report.save
  	found = Report.find_by_content('বাংলা')
  	_(found).must_equal report
  end

  it 'wont make impact report orphans when changing report type' do
    updater = Report::Updater.new(report)
    params = {'challenge_report' => '1', 'impact_report' => '0'}
    updater.update_report(params)
    _(report.impact_report).must_be_nil
    _(ImpactReport).wont_be :exists?, impact_report.id
  end

  it 'wont make challenge report orphans when changing report type' do
    challenge = ChallengeReport.new
    report.challenge_report = challenge
    updater = Report::Updater.new(report)
    params = {'challenge_report' => '0', 'impact_report' => '1'}
    updater.update_report(params)
    _(ChallengeReport).wont_be :exists?, challenge.id
  end

  it 'wont make planning report orphans when changing report type' do
    planning = PlanningReport.new
    report.planning_report = planning
    updater = Report::Updater.new(report)
    params = {'planning_report' => '0', 'impact_report' => '1'}
    updater.update_report(params)
    _(PlanningReport).wont_be :exists?, planning.id
  end

  it 'scopes to let non-sensitive users see only their own reports' do
    own_report = report.dup
    non_sensitive_user = FactoryBot.create(:user, trusted = false)
    own_report.reporter = non_sensitive_user
    own_report.impact_report = ImpactReport.create
    report.save!
    own_report.save!
    reports = Report.user_limited(non_sensitive_user)
    _(reports).must_include own_report
    _(reports).wont_include report
  end

end
