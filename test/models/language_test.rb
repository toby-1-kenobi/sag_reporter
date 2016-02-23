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
  
end
