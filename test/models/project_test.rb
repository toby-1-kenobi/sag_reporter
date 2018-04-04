require "test_helper"

describe Project do
  let(:project) { Project.new }

  it "must be valid" do
    value(project).must_be :valid?
  end
end
