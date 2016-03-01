class ImpactReport < ActiveRecord::Base

  include StateBased

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  has_one :report, inverse_of: :impact_report
  has_many :topics, through: :progress_markers
  has_and_belongs_to_many :progress_markers
  has_and_belongs_to_many :languages, allow_nil: false

  validates :state, presence: true
  validates :report_date, presence: true
  validates :content, presence: true
  validates :report, presence: true

  after_initialize :state_init
  after_initialize :date_init

  def report_type
    "impact"
  end

  def topic
    return false
  end

  private

    def state_init
      self.state ||= :active
    end

    def date_init
      self.report_date ||= self.event ? self.event.event_date : Date.current
    end

end
