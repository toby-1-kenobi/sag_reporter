require "test_helper"

describe Report::Updater do

  let(:updater) { Report::Updater.new(report) }
  let(:report) { Report.new(
      reporter: users(:andrew),
      geo_state: geo_states(:assam),
      content: "This is a test report",
      impact_report: impact_report,
      report_date: Date.new(2016, 3, 1)) }
  let(:impact_report) { ImpactReport.new }

  it "updates reports" do
    updater.instance.languages << languages(:assamese)
    updater.instance.topics << topics(:movement_building)
    report_params = {
      "geo_state_id"=>"#{geo_states(:assam).id}",
      "content"=>"This is an updated report",
      "impact_report"=>"0",
      "planning_report"=>"1",
      "challenge_report"=>"0",
      "report_date"=>"2 March, 2016",
      "mt_society"=>"0",
      "mt_church"=>"0",
      "needs_society"=>"0",
      "needs_church"=>"0",
      "languages"=>["#{state_languages(:assam_english).id}", "#{state_languages(:assam_assamese).id}"]
    }
    result = updater.update_report(report_params)
    _(result).must_equal true
    _(updater.instance.content).must_equal "This is an updated report"
    _(updater.instance.languages.count).must_equal 2
    _(updater.instance).must_be :planning_report?
  end

end
