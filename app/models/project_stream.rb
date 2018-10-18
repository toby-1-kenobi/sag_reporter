class ProjectStream < ActiveRecord::Base
  belongs_to :project
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  has_many :supervisor_feedbacks, dependent: :nullify
  validates :project, presence: true
  validates :ministry, presence: true
  validates :stage, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
