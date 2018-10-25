class ProjectLanguage < ActiveRecord::Base

  belongs_to :project
  belongs_to :state_language

  validates :project, presence: true
  validates :state_language, presence: true, uniqueness: { scope: :project }

  after_create do |project_language|
    project_language.project.touch
  end

  after_destroy do |project_language|
    project_language.project.touch
  end

  after_update do |project_language|
    project_language.project.touch
  end

end
