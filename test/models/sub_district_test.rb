require "test_helper"

describe SubDistrict do
  let(:sub_district) { SubDistrict.new name: "Test", district: district }
  let(:district) { District.new }

  it "must be valid" do
    value(sub_district).must_be :valid?
  end

  it "wont be valid without a name" do
    sub_district.name = ""
    value(sub_district).wont_be :valid?
  end

  it "wont be valid without a state" do
    sub_district.district = nil
    value(sub_district).wont_be :valid?
  end

end
