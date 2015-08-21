class ActionPoint < ActiveRecord::Base

  enum status: [ :incomplete, :complete ]

  belongs_to :responsible, class_name: 'Person'
  belongs_to :record_creator, class_name: 'User'
  belongs_to :event
  
end
