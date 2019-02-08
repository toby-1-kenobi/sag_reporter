class QuarterlyEvaluation < ActiveRecord::Base

  has_paper_trail

  enum progress: {
      no_progress: 0,
      poor: 1,
      fair: 2,
      good: 3,
      excellent: 4
  }

  belongs_to :project
  belongs_to :sub_project
  belongs_to :state_language
  belongs_to :ministry
  belongs_to :report

  validates :project, presence: true
  validates :state_language, presence: true
  validates :ministry, presence: true
  validates :quarter, presence: true, format: { with: /\A[2-9]\d{3}-[1-4]\z/, message: "should be in the format 'YYYY-Q'" }
  validate :sub_project_in_project

  def unused?
    question_1.blank? and question_2.blank? and
        question_1.blank? and question_3.blank? and
        not approved? and report_id.blank? and progress.blank?
  end

  def used?
    not unused?
  end

  private

  def sub_project_in_project
    if sub_project
      errors.add(:sub_project, 'must be in project') unless sub_project.project_id == project_id
    end
  end

end
