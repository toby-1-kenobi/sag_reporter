class LanguageStream < ActiveRecord::Base

  has_paper_trail

  belongs_to :ministry
  belongs_to :state_language
  belongs_to :facilitator, class_name: 'User'
  belongs_to :project
  belongs_to :sub_project

  validates :ministry, presence: true
  validates :state_language, presence: true
  validate :sub_project_in_project

  after_update do
    bring_quarterly_evaluations(sub_project_id_was, sub_project_id) if sub_project_id_changed?
  end

  before_destroy do
    bring_quarterly_evaluations(sub_project_id, nil)
  end

  private

  def sub_project_in_project
    if sub_project.present? and project.present?
      errors.add(:sub_project, 'must be a member of project') unless sub_project.project == project
    end
  end

  # if we change the sub-project and no language-streams remain in the old sub-project
  # then bring all related quarterly evaluations across to the new sub-project
  def bring_quarterly_evaluations(from_sub_project, to_sub_project)
    unless LanguageStream.where(project: project, sub_project_id: from_sub_project, ministry: ministry, state_language: state_language).
        where.not(id: id).exists?
      QuarterlyEvaluation.where(project: project, sub_project_id: from_sub_project, ministry: ministry, state_language: state_language).each do |qe|
        if qe.unused?
          # remove the qe if it's not used
          qe.destroy
        else
          # check for other qe occupying the spot we'll move this one too
          occupied = false
          QuarterlyEvaluation.where.not(id: qe.id).
              where(project: project, sub_project_id: to_sub_project, ministry: ministry, state_language: state_language, quarter: qe.quarter).
              each do |qe2|
            if qe2.unused?
              qe2.destroy
            else
              occupied = true
            end
          end
          # if there's already a used qe object there, move it to the project level
          to_sub_project = nil if occupied
          qe.update_attributes(sub_project_id: to_sub_project)
        end
      end
    end
  end

end
