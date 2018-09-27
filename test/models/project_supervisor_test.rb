require "test_helper"

describe ProjectSupervisor do
  let(:project_supervisor) { FactoryBot.build(:project_supervisor) }

  it "must be valid" do
    value(project_supervisor).must_be :valid?
  end
end
