require "test_helper"

describe ProjectLanguage do
  let(:project_language) { FactoryBot.build(:project_language) }

  it "must be valid" do
    value(project_language).must_be :valid?
  end
end
