require 'test_helper'

describe Project do
  let(:project) { FactoryBot.create(:project)}

  it 'must be valid' do
    value(project).must_be :valid?
  end

  it 'must scope to a state' do
    # state membership of a project is determined by its languages
    language_a = FactoryBot.create(:language)
    state_a = language_a.geo_states.first
    project.languages << language_a
    other_project = FactoryBot.create(:project)
    state_a_projects = Project.in_states(state_a)
    _(state_a_projects).must_include project
    _(state_a_projects).wont_include other_project
  end

  it 'must scope to a zone' do
    # zone membership of a project is determined by its languages
    language_a = FactoryBot.create(:language)
    state_a = language_a.geo_states.first
    zone_a = state_a.zone
    project.languages << language_a
    other_project = FactoryBot.create(:project)
    zone_a_projects = Project.in_zones(zone_a)
    _(zone_a_projects).must_include project
    _(zone_a_projects).wont_include other_project
  end

end
