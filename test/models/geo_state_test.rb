require 'test_helper'

describe GeoState do

  let(:north_east_zone) { Zone.create name: "Test North East"}
  let(:assam_state) { GeoState.new name: "Test Assam", zone: north_east_zone }
  let(:minority_language) { Language.new name: "Test Toto", lwc: false }
  let(:state_language) { Language.new name: "Test Assamese", lwc: true }

  it "must be valid" do
    value(assam_state).must_be :valid?
  end

  it "returns its zone's id" do
  	value(assam_state.zone_id).must_equal north_east_zone.id
  end

  it "returns its minority languages" do
    assam_state.languages << minority_language
    assam_state.languages << state_language
    assam_state.save
    _(assam_state).must_be :persisted?
    _(assam_state.minority_languages).must_include minority_language
    _(assam_state.minority_languages).wont_include state_language
  end
  
end
