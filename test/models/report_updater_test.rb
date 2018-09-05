require "test_helper"

describe Report::Updater do

  let(:updater) { Report::Updater.new(report) }
  let(:report) { FactoryBot.create(:report) }
  let(:english) { FactoryBot.create(:language, name: "English", iso: "eng") }
  let(:assamese) { FactoryBot.create(:language, name: "Assamese", iso: "asa") }

  it "updates reports" do
    geo_state = FactoryBot.create(:geo_state)
    updater.instance.languages << FactoryBot.create(:language)
    report_params = {
      "geo_state_id"=>"#{geo_state.id}",
      "content"=>"This is an updated report",
      "impact_report"=>"0",
      "planning_report"=>"1",
      "challenge_report"=>"0",
      "report_date"=>"2 March, 2016",
      "languages"=>[
          "#{FactoryBot.create(:state_language, language: english, geo_state: geo_state).id}",
          "#{FactoryBot.create(:state_language, language: assamese, geo_state: geo_state).id}"
      ]
    }
    result = updater.update_report(report_params)
    _(result).must_equal true
    _(updater.instance.content).must_equal "This is an updated report"
    _(updater.instance.languages.count).must_equal 2
    _(updater.instance).must_be :planning_report?
  end

end
