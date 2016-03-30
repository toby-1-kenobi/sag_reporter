require 'test_helper'

describe Report do

  let(:report) { Report.new(
    content: 'report content',
    reporter: users(:andrew),
    geo_state: geo_states(:nb),
    status: :active,
    report_date: Date.today,
    sub_district: sub_district,
    location: 'some place'
  ) }
  let(:impact_report) { ImpactReport.new }
  let(:sub_district) { SubDistrict.new district: district}
  let(:district) { District.new geo_state: geo_states(:nb) }

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
  	report.languages << Language.take(2)
  	_(report.languages.length).must_equal 2
  end

  it 'may have many topics' do
  	report.topics << Topic.take(2)
  	_(report.topics.length).must_equal 2
  end

  it 'may have content in various scripts' do
  	report.content = 'বাংলা'
  	report.save
  	found = Report.find_by_content('বাংলা')
  	_(found).must_equal report
  end

end
