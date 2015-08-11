class ActionPoint < ActiveRecord::Base
  belongs_to :responsible, class_name: 'Person'
  belongs_to :record_creator, class_name: 'User'
  belongs_to :event
end
