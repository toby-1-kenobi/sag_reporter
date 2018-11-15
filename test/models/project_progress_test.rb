require "test_helper"

describe ProjectProgress do
  let(:project_progress) { FactoryBot.build(:project_progress) }

  it "must be valid" do
    value(project_progress).must_be :valid?
  end
end
