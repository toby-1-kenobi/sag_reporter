class ImpactReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :impact_report, dependent: :nullify
  has_and_belongs_to_many :progress_markers
  has_many :topics, through: :progress_markers

  validates :shareable, :inclusion => {:in => [true, false]}

  def report_type
    "impact"
  end

  def make_not_impact
    report.make_not_impact
  end

end
