class ImpactReport < ActiveRecord::Base

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  belongs_to :progress_marker
  delegate :topic, to: :progress_marker, :allow_nil => true
  has_and_belongs_to_many :languages

end
