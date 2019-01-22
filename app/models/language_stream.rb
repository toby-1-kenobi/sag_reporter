class LanguageStream < ActiveRecord::Base

  belongs_to :ministry
  belongs_to :state_language
  belongs_to :facilitator, class_name: 'User'
  belongs_to :project
  belongs_to :sub_project

  validates :ministry, presence: true
  validates :state_language, presence: true
  validate :sub_project_in_project

  after_update :bring_quarterly_evaluations, if: -> { sub_project_id_changed? }

  private

  def sub_project_in_project
    if sub_project.present? and project.present?
      errors.add(:sub_project, 'must be a member of project') unless sub_project.project == project
    end
  end

  # if we change the sub-project and no language-streams remain in the old sub-project
  # then bring all related quarterly evaluations across to the new sub-project
  def bring_quarterly_evaluations
    unless LanguageStream.where(project: project, sub_project_id: sub_project_id_was, ministry: ministry, state_language: state_language).
        where.not(id: id).exists?
      QuarterlyEvaluation.where(project: project, sub_project_id: sub_project_id_was, ministry: ministry, state_language: state_language).
          update_all(sub_project_id: sub_project_id)
    end
  end

end
