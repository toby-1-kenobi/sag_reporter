require "test_helper"

describe ChurchTeamMembership do
  let(:church_team_membership) { FactoryBot.build(:church_team_membership) }

  it "must be valid" do
    value(church_team_membership).must_be :valid?
  end
end
