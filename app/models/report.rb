class Report < ActiveRecord::Base

  include StateBased

	enum state: [ :archived, :active ]

	belongs_to :reporter, class_name: 'User'
	belongs_to :event
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics

	validates :content, presence: true, allow_nil: false
	validates :reporter, presence: true, allow_nil: false
  validates :state, presence: true, allow_nil: false
  validates :report_date, presence: true

  after_initialize :state_init
  after_initialize :date_init

  def self.categories
    {
      'mt_society' => Translatable.find_by_identifier('mt_in_society'),
      'mt_church' => Translatable.find_by_identifier('mt_in_church'),
      'needs_society' => Translatable.find_by_identifier('needs_society'),
      'needs_church' => Translatable.find_by_identifier('needs_church')
    }
  end

  def report_type
    "planning"
  end

  private

    def state_init
      self.state ||= :active
    end

    def date_init
      self.report_date ||= self.event ? self.event.event_date : Date.current
    end

end
