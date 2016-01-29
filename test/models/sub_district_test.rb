require "test_helper"

describe SubDistrict do
  let(:sub_district) { SubDistrict.new name: "Test", district: district }
  let(:district) { District.new }

  it "must be valid" do
    value(sub_district).must_be :valid?
  end

  it "wont be valid without a name" do
    sub_district.name = ""
    sub_district.valid?
    value(sub_district.errors[:name]).must_be :any?
  end

  it "wont be valid without a state" do
    sub_district.district = nil
    sub_district.valid?
    value(sub_district.errors[:district]).must_be :any?
  end

  it "must have a unique name within it's district" do
    sub_district.district = District.take
    sd2 = district.dup
    sub_district.save
    sd2.valid?
    value(sd2.errors[:name]).must_be :any?
  end

  it "may have non-unique name if in different geo_states" do
    sd2 = sub_district.dup
    sub_district.district = District.take
    sd2.district = district
    sub_district.save
    value(sd2).must_be :valid?
  end

end
