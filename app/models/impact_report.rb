class ImpactReport < ActiveRecord::Base

  enum state: [ :archived, :active ]

  belongs_to :reporter, class_name: 'User'
  belongs_to :event
  belongs_to :progress_marker
  
end
