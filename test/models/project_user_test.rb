require "test_helper"

describe ProjectUser do

  it "must be valid" do
    value(project_users(:andrew_one)).must_be :valid?
  end

end
