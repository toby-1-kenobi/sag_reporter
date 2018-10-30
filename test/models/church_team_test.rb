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

  it "scopes to a project" do
    project = FactoryBot.create(:project)
    state_lang = FactoryBot.create(:state_language)
    ministry = FactoryBot.create(:ministry)
    project.state_languages << state_lang
    project.ministries << ministry
    church_team.state_language = state_lang
    church_team.save
    church_team.ministries << ministry
    # ct2 right stream, wrong language
    ct2 = FactoryBot.create(:church_team)
    ct2.ministries << ministry
    # ct3 right language, wrong stream
    ct3 = FactoryBot.create(:church_team, state_language: state_lang)
    teams = ChurchTeam.in_project(project)
    teams.must_include church_team
    teams.wont_include ct2
    teams.wont_include ct3
  end

end
