class LanguageStream < ActiveRecord::Base

  belongs_to :ministry
  belongs_to :state_language
  belongs_to :facilitator, class_name: 'User'
  belongs_to :project
  belongs_to :sub_project

  validates :ministry, presence: true
  validates :state_language, presence: true
  validate :sub_project_in_project

  private

  def sub_project_in_project
    if sub_project.present? and project.present?
      errors.add(:sub_project, 'must be a member of project') unless sub_project.project == project
    end
  end

end
