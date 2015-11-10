class ImpactReport < ActiveRecord::Base

  include StateBased

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  has_many :topics, through: :progress_markers
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :progress_markers

  def report_date
  	event ? event.event_date : created_at
  end

  def report_type
    "impact"
  end

  def topic
    return false
  end

end
