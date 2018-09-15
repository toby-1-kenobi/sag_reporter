require "test_helper"

describe StateProject do
  let(:state_project) { FactoryBot.build(:state_project) }

  it "must be valid" do
    value(state_project).must_be :valid?
  end
end
