class PlanningReport < ActiveRecord::Base
  enum status: [ :archived, :active ]
  has_one :report, inverse_of: :planning_report

  def report_type
    "planning"
  end
end
