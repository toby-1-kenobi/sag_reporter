class PlanningReport < ActiveRecord::Base

  has_paper_trail

  include ReportType

  has_one :report, inverse_of: :planning_report
  validates_presence_of :report

  after_destroy { report.update_columns(planning_report_id: nil) if report.persisted? }

  def report_type
    'planning'
  end

end
