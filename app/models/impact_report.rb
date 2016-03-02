class ImpactReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :impact_report, dependent: :nullify
  has_and_belongs_to_many :progress_markers
  has_many :topics, through: :progress_markers

  def report_type
    "impact"
  end

end
