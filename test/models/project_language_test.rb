require "test_helper"

describe ProjectLanguage do

  let(:project_language) { FactoryBot.build(:project_language) }

  it "must be valid" do
    value(project_language).must_be :valid?
  end

  it "must update project when a new language is added" do
    project = FactoryBot.create(:project, updated_at: 1.day.ago)
    init_value = project.updated_at
    FactoryBot.create(:project_language, project: project)
    project.reload
    _(project.updated_at).must_be :>, init_value
  end

  it "must update project when a language is removed" do
    project = FactoryBot.create(:project)
    project_language = FactoryBot.create(:project_language, project: project)
    init_value = project.updated_at
    travel 1.day
    project_language.destroy
    project.reload
    _(project.updated_at).must_be :>, init_value
  end

  it "must update project when a language is changed" do
    project = FactoryBot.create(:project)
    project_language = FactoryBot.create(:project_language, project: project)
    init_value = project.updated_at
    travel 1.day
    project_language.state_language = FactoryBot.create(:state_language)
    project_language.save
    project.reload
    _(project.updated_at).must_be :>, init_value
  end

end
