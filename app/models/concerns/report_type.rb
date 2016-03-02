module ReportType

  extend ActiveSupport::Concern

  included do
    delegate :content, to: :report
    delegate :reporter, to: :report
    delegate :event, to: :report
    delegate :report_date, to: :report
    delegate :geo_state, to: :report
    delegate :languages, to: :report
    delegate :status, to: :report
    delegate :active?, to: :report
    delegate :archived?, to: :report

    validates :report, presence: true
  end

  def active!
    report.active!
  end

  def archived!
    report.archived!
  end

end