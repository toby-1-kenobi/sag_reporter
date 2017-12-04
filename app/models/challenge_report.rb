class ChallengeReport < ActiveRecord::Base

  include ReportType

  has_one :report, inverse_of: :challenge_report, dependent: :nullify
  validates_presence_of :report

  def report_type
    'challenge'
  end
end
