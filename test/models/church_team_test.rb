require 'test_helper'

describe ChurchTeam do

  let(:church_team) { FactoryBot.build(:church_team) }

  it "must be valid" do
    value(church_team).must_be :valid?
  end

  it "must update timestamp when a user is added" do
    church_team.save
    init_value = church_team.updated_at
    church_team.users << FactoryBot.create(:user)
    church_team.reload
    _(church_team.updated_at).must_be :>, init_value
  end

  it "must update timestamp when a user is removed" do
    church_team.save
    user = FactoryBot.create(:user)
    church_team.users << user
    church_team.reload
    init_value = church_team.updated_at
    church_team.users.destroy user
    church_team.reload
    _(church_team.updated_at).must_be :>, init_value
  end

end
