require "test_helper"

describe ChurchMinistry do
  let(:church_ministry) { FactoryBot.build(:church_ministry) }

  it "must be valid" do
    value(church_ministry).must_be :valid?
  end
end
