require "test_helper"

describe ProjectStream do
  let(:project_streams) { FactoryBot.build(:project_streams) }

  it "must be valid" do
    value(project_stream).must_be :valid?
  end
end
