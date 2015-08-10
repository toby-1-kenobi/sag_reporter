class ImpactReport < ActiveRecord::Base

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  belongs_to :progress_marker
  has_and_belongs_to_many :languages

end
