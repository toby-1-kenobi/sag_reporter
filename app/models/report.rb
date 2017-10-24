class Report < ActiveRecord::Base

  include LocationBased

	enum status: [ :active, :archived ]

	belongs_to :reporter, class_name: 'User'
	belongs_to :event
  belongs_to :planning_report, inverse_of: :report
  belongs_to :impact_report, inverse_of: :report, touch: true
  belongs_to :challenge_report, inverse_of: :report
	has_and_belongs_to_many :languages, after_add: :update_self, after_remove: :update_self
	has_and_belongs_to_many :topics
  has_many :pictures, class_name: 'UploadedFile', dependent: :nullify, after_add: :update_self, after_remove: :update_self
  has_many :observations, inverse_of: :report, dependent: :destroy
  has_many :observers, through: :observations, source: 'person', after_add: :update_self, after_remove: :update_self
  accepts_nested_attributes_for :pictures,
                                allow_destroy: true,
                                reject_if: :all_blank
  accepts_nested_attributes_for :observers,
                                reject_if: :all_blank
  accepts_nested_attributes_for :impact_report

  delegate :name, to: :sub_district, prefix: true
  delegate :name, to: :district, prefix: true

	validates :content, presence: true, allow_nil: false
	validates :reporter, presence: true, allow_nil: false
  validates :status, presence: true, allow_nil: false
  validates :report_date, presence: true
  validates :client, presence: true # a string identifying by which application the report was submitted
  validate :at_least_one_subtype
  #validate :location_present_for_new_record

  before_validation :date_init

  scope :reporter, -> user {
    where(reporter: user)
  }

  scope :states, -> geo_states {
    where(geo_state: geo_states)
  }

  scope :language, -> lang {
    joins(:languages).where(languages: {id: lang.id})
  }

  scope :since, -> since_date {
    where('report_date >= ?', since_date)
  }

  scope :until, -> until_date {
    where('report_date <= ?', until_date)
  }

  scope :significant, -> {
    where(significant: true)
  }

  scope :types, -> types {
    if types.empty?
      none
    elsif types.count == 1
      where.not("#{types.first.to_s}_report_id" => nil)
    else
      query = types.map{ |t| "reports.#{t.to_s}_report_id IS NOT NULL"}.join ' OR '
      where query
    end
  }

  scope :translation_impact, -> {
    joins(:impact_report).where(impact_reports: {translation_impact: true})
  }

  scope :user_limited, -> user {
    if user.national?
      all
    else
      joins(:geo_state).where('geo_states.id' => user.geo_states)
    end
  }

  def translation_impact?
    impact_report and impact_report.translation_impact?
  end

  def self.categories
    {
      'mt_society' => Translatable.find_by_identifier('mt_in_society'),
      'mt_church' => Translatable.find_by_identifier('mt_in_church'),
      'needs_society' => Translatable.find_by_identifier('needs_society'),
      'needs_church' => Translatable.find_by_identifier('needs_church')
    }
  end

  def report_type_a
    types = Array.new
    types << planning_report.report_type if planning_report
    types << impact_report.report_type if impact_report
    types << challenge_report.report_type if challenge_report
    return types
  end

  def report_type
    report_type_a.to_sentence.humanize
  end

  def full_location
    if geo_state.present?
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
    else
      nil
    end
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

  # Apply a set of filters to a collection of reports
  # return the filtered collection
  def self.filter(collection, filters)
    # here we're trusting the Date.parse function will be able to handle whatever format comes its way in this context
    collection = collection.since Date.parse(filters[:since]) if filters[:since]
    collection = collection.until Date.parse(filters[:until]) if filters[:until]
    collection = collection.active unless filters[:archived].present?
    collection = collection.significant if filters[:significant].present?
    # before filtering for report types check that we are using this filter
    if filters[:report_types].present?
      # for an empty list of types the scope will return an empty collection
      filters[:types] ||= []
      collection = collection.types(filters[:types])
    end
    # before filtering for states check that we are using this filter
    if filters[:states_filter].present?
      # for an empty list of types the scope will return an empty collection
      filters[:states] ||= []
      collection = collection.states(filters[:states])
    end
    # before filtering for type of impact check impact type is selected (if we are using type filter)
    if filters[:report_types].blank? or filters[:types].include? 'impact'
      collection = collection.translation_impact if filters[:translation_impact] == 'true'
    end
    collection
  end

  def update_self object
    self.touch
  end

  private

  def date_init
    self.report_date ||= self.event ? self.event.event_date : Date.current
  end

  def at_least_one_subtype
    unless self.planning_report? or self.impact_report? or self.challenge_report?
      self.errors.add(:base, 'Must have at least one report type.')
    end
  end

end
