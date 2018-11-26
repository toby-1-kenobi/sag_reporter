require "test_helper"

describe SubProject do
  let(:sub_project) { FactoryBot.build(:sub_project) }

  it "must be valid" do
    value(sub_project).must_be :valid?
  end
end
