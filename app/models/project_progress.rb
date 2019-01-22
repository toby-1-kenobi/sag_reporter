class ProjectProgress < ActiveRecord::Base

  has_paper_trail

  enum progress: {
      no_progress: 0,
      poor: 1,
      fair: 2,
      good: 3,
      excellent: 4
  }

  belongs_to :project_stream

  validates :project_stream, presence: true
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'"}
  validates :approved, inclusion: [true, false]

end
