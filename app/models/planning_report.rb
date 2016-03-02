class PlanningReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :planning_report, dependent: :nullify

  def report_type
    "planning"
  end

end
