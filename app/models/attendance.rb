class Attendance < ActiveRecord::Base

  belongs_to :person
  belongs_to :event

  validates :person, presence: true
  validates :event, presence: true
  
end
