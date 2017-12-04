class PlanningReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :planning_report, dependent: :nullify
  validates_presence_of :report

  def report_type
    'planning'
  end

end
