require "test_helper"

describe Report::Updater do

  let(:updater) { Report::Updater.new(report) }
  let(:report) { Report.new(
      reporter: FactoryBot.build(:user),
      geo_state: FactoryBot.build(:geo_state),
      content: "This is a test report",
      impact_report: impact_report,
      report_date: Date.new(2016, 3, 1)) }
  let(:impact_report) { ImpactReport.new }
  let(:english) { FactoryBot.build(:language, name: "English", iso: "eng") }
  let(:assamese) { FactoryBot.build(:language, name: "Assamese", iso: "asa") }

  it "updates reports" do
    updater.instance.languages << FactoryBot.build(:language)
    updater.instance.topics << FactoryBot.build(:topic)
    report_params = {
      "geo_state_id"=>"#{FactoryBot.create(:geo_state).id}",
      "content"=>"This is an updated report",
      "impact_report"=>"0",
      "planning_report"=>"1",
      "challenge_report"=>"0",
      "report_date"=>"2 March, 2016",
      "mt_society"=>"0",
      "mt_church"=>"0",
      "needs_society"=>"0",
      "needs_church"=>"0",
      "languages"=>[
          "#{FactoryBot.create(:state_language, language: english).id}",
          "#{FactoryBot.create(:state_language, language: assamese).id}"
      ]
    }
    result = updater.update_report(report_params)
    _(result).must_equal true
    _(updater.instance.content).must_equal "This is an updated report"
    _(updater.instance.languages.count).must_equal 2
    _(updater.instance).must_be :planning_report?
  end

end
