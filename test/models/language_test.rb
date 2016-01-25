require 'test_helper'

describe Language do

  let(:language) { Language.new name: "Test language", lwc: false}
  let(:assam) { GeoState.new name: "Assam"}
  let(:bihar) { GeoState.new name: "bihar"}

  it "must be valid" do
    value(language).must_be :valid?
  end

  it "returns its states ids" do
  	language.geo_states << assam
  	language.geo_states << bihar
  	assam.stub(:id, 8) do
  	  bihar.stub(:id, 13) do
  	    value(language.geo_state_ids_str).must_equal "8,13"
  	  end
  	end
  end

  it "totals all outcome area scores" do
    outcome_areas = [stub, stub, stub]
    Topic.expects(:all).returns outcome_areas
    language.expects(:outcome_month_score).times(3).returns(5,7,3)
    language.total_month_score(assam, 2015, 11).must_equal 15
  end
  
end
