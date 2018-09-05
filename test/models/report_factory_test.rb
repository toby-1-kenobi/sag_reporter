require "test_helper"

describe Report::Factory do

  let(:factory) { Report::Factory.new }

  it "makes valid reports" do
    languages = FactoryBot.create_list(:language, 2)
    report_params = {
      "content"=>"This is a test report",
      "impact_report"=>"1",
      "planning_report"=>"1",
      "report_date"=>"1 March, 2016",
      "languages"=>languages.map{ |lang| lang.id.to_s },
      "geo_state_id"=>languages.first.geo_states.first.id.to_s,
      "reporter_id"=>FactoryBot.create(:user).id.to_s
    }
    _(result = factory.build_report(report_params)).must_equal true
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