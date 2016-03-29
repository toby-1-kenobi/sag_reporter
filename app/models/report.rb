class Report < ActiveRecord::Base

  include LocationBased

	enum status: [ :active, :archived ]

	belongs_to :reporter, class_name: 'User'
	belongs_to :event
  belongs_to :planning_report, inverse_of: :report
  belongs_to :impact_report, inverse_of: :report
  belongs_to :challenge_report, inverse_of: :report
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics
  has_many :pictures, class_name: 'UploadedFile'
  accepts_nested_attributes_for :pictures,
    allow_destroy: true,
    reject_if: :all_blank

  delegate :name, to: :sub_district, prefix: true
  delegate :name, to: :district, prefix: true

	validates :content, presence: true, allow_nil: false
	validates :reporter, presence: true, allow_nil: false
  validates :status, presence: true, allow_nil: false
  validates :report_date, presence: true
  validate :at_least_one_subtype
  validate :location_present_for_new_record

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
    types.to_sentence.humanize
  end

  def full_location
    location_data = Array.new
    location_data << geo_state.name
    if sub_district.present?
      location_data << district_name
      location_data << sub_district_name
    end
    if location.present?
      location_data << location
    end
    location_data.join ', '
  end

  def planning_report?
    self.planning_report.present?
  end

  def impact_report?
    self.impact_report.present?
  end

  def challenge_report?
    self.challenge_report.present?
  end

  def make_not_impact
    self.impact_report.destroy if self.impact_report? and self.impact_report.persisted?
    if !self.planning_report? && !self.challenge_report?
      self.planning_report = PlanningReport.new
      self.save
    end
  end

  private

  def date_init
    self.report_date ||= self.event ? self.event.event_date : Date.current
  end

  def at_least_one_subtype
    unless self.planning_report? or self.impact_report? or self.challenge_report?
      self.errors.add(:base, "Must have at least one report type.")
    end
  end

end
