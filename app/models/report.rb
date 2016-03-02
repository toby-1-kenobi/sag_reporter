class Report < ActiveRecord::Base

  include StateBased

	enum status: [ :active, :archived ]

	belongs_to :reporter, class_name: 'User'
	belongs_to :event
  belongs_to :planning_report, inverse_of: :report
  belongs_to :impact_report, inverse_of: :report
  belongs_to :challenge_report, inverse_of: :report
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics

	validates :content, presence: true, allow_nil: false
	validates :reporter, presence: true, allow_nil: false
  validates :status, presence: true, allow_nil: false
  validates :report_date, presence: true
  validate :at_least_one_subtype

  before_validation :date_init

  def self.categories
    {
      'mt_society' => Translatable.find_by_identifier('mt_in_society'),
      'mt_church' => Translatable.find_by_identifier('mt_in_church'),
      'needs_society' => Translatable.find_by_identifier('needs_society'),
      'needs_church' => Translatable.find_by_identifier('needs_church')
    }
  end

  def report_type
    types = Array.new
    types << planning_report.report_type if planning_report
    types << impact_report.report_type if impact_report
    types << challenge_report.report_type if challenge_report
    types.join ', '
  end

  private

    def date_init
      self.report_date ||= self.event ? self.event.event_date : Date.current
    end

    def at_least_one_subtype
      unless planning_report or impact_report or challenge_report
        errors.add(:base, "Must have at least one report type.")
      end
    end

end
