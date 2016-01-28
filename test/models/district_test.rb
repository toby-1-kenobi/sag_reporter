require "test_helper"

describe District do
  let(:district) { District.new name: "Test", geo_state: geo_state }
  let(:geo_state) { GeoState.new }

  it "must be valid" do
    value(district).must_be :valid?
  end

  it "wont be valid without a name" do
    district.name = ""
    value(district).wont_be :valid?
  end

  it "wont be valid without a state" do
    district.geo_state = nil
    value(district).wont_be :valid?
  end

end
