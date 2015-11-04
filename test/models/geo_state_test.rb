require 'test_helper'

describe GeoState do

  let(:north_east_zone) { Zone.new name: "North East"}
  let(:assam_state) { GeoState.new name: "Assam", zone: north_east_zone }
  let(:minority_language) { Language.new name: "Toto", lwc: false }
  let(:state_language) { Language.new name: "Assamese", lwc: true }

  it "must be valid" do
    value(assam_state).must_be :valid?
  end

  it "returns its zone's id" do
  	north_east_zone.stub(:id, 8) do
  	  value(assam_state.zone_id).must_equal north_east_zone.id
  	end
  end

  it "returns its minority languages" do
    assam_state.languages << minority_language
    assam_state.languages << state_language
    assam_state.minority_languages.must_include minority_language
    assam_state.minority_languages.wont_include state_language
  end
  
end
