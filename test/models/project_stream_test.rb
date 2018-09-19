require "test_helper"

describe ProjectStream do
  let(:project_stream) { FactoryBot.build(:project_stream) }

  it "must be valid" do
    value(project_stream).must_be :valid?
  end
end
