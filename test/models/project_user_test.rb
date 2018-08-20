require "test_helper"

describe ProjectUser do

  let (:project_user) { ProjectUser.new project: FactoryBot.build(:project), user: FactoryBot.build(:user) }

  it "must be valid" do
    value(project_user).must_be :valid?
  end

end
