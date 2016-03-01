class ChallengeReport < ActiveRecord::Base

  enum status: [ :archived, :active ]

  has_one :report, inverse_of: :challenge_report
  delegate :content, to: :report
  delegate :reporter, to: :report
  delegate :event, to: :report
  delegate :report_date, to: :report

  validates :report, presence: true

  def report_type
    "challenge"
  end
end
