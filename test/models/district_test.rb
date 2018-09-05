require "test_helper"

describe District do
  let(:geo_state) { GeoState.new }
  let(:sub_district) { SubDistrict.new name: "Test" }
  let(:district) { District.new name: "Test", geo_state: geo_state, sub_districts: [sub_district] }

  it "must be valid" do
    value(district).must_be :valid?
  end

  it "wont be valid without a name" do
    district.name = ""
    district.valid?
    value(district.errors[:name]).must_be :any?
  end

  it "wont be valid without a state" do
    district.geo_state = nil
    district.valid?
    value(district.errors[:geo_state]).must_be :any?
  end

  it "must have a unique name within it's geo_state" do
    district.geo_state = FactoryBot.create(:geo_state)
    d2 = district.dup
    district.save
    d2.valid?
    value(d2.errors[:name]).must_be :any?
  end

  it "may have non-unique name if in different geo_states" do
    d2 = district.dup
    district.geo_state = FactoryBot.create(:geo_state)
    d2.geo_state = geo_state
    d2.sub_districts = [sub_district]
    district.save
    value(d2).must_be :valid?
  end

end
