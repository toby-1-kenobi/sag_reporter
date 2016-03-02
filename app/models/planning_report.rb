class PlanningReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :planning_report

  def report_type
    "planning"
  end

end
