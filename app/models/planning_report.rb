class PlanningReport < ActiveRecord::Base

  enum status: [ :archived, :active ]
  
  has_one :report, inverse_of: :planning_report
  delegate :content, to: :report
  delegate :reporter, to: :report
  delegate :event, to: :report
  delegate :report_date, to: :report

  def report_type
    "planning"
  end

end
