class ProjectProgress < ActiveRecord::Base

  belongs_to :project_stream

  validates :project_stream, presence: true
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'"}
  validates :approved, inclusion: [true, false]

end
