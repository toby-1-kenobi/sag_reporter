require "test_helper"

describe Report::Factory do

  let(:factory) { Report::Factory.new }

  it "makes valid reports" do
    report_params = {
      "geo_state_id"=>"#{geo_states(:nb).id}",
      "content"=>"This is a test report",
      "impact_report"=>"1",
      "planning_report"=>"1",
      "report_date"=>"1 March, 2016",
      "mt_society"=>"0",
      "mt_church"=>"0",
      "needs_society"=>"0",
      "needs_church"=>"0",
      "languages"=>["#{languages(:toto).id}", "#{languages(:santali).id}"],
      "topics"=>["#{topics(:movement_building)}", "#{topics(:social_development)}"],
      reporter: users(:andrew)
    }
    _(factory.build_report(report_params)).must_equal true
    _(factory.instance()).must_be :valid?
  end

  it "fails gracefully when creating with bad parameters" do
    report_params = {
      content: "Test report", 
      report_date: "foobar"
    }
    _(factory.create_report(report_params)).must_equal false
  end

  it "fails gracefully with unknown parameters" do
    report_params = {
      content: "Test Report", 
      what: "huh?"
    }
    _(factory.build_report(report_params)).must_equal false
  end

end