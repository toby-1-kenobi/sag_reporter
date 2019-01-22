class ProjectStream < ActiveRecord::Base

  has_paper_trail

  belongs_to :project
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  has_many :project_progresses

  validates :project, presence: true
  validates :ministry, presence: true
  validates :stage, presence: true, numericality: { greater_than_or_equal_to: 0 }

end
