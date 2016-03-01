class ImpactReport < ActiveRecord::Base

  include StateBased

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  has_one :report, inverse_of: :impact_report
  has_many :topics, through: :progress_markers
  has_and_belongs_to_many :progress_markers
  has_and_belongs_to_many :languages, allow_nil: false

  delegate :content, to: :report
  delegate :reporter, to: :report
  delegate :event, to: :report
  delegate :report_date, to: :report
  delegate :geo_state, to: :report
  #delegate :languages, to: :report

  validates :state, presence: true
  validates :report_date, presence: true
  validates :content, presence: true
  validates :report, presence: true
  validates :languages, presence: true

  after_initialize :state_init

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

end
