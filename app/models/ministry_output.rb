class MinistryOutput < ActiveRecord::Base
  belongs_to :church_congregation
  belongs_to :ministry_marker

  validates :church_congregation, presence: true
  validates :ministry_marker, presence: true
  validates :year, presence: true, inclusion: 2018..(Time.now.year + 50)
  validates :month, presence: true, inclusion: 1..12
  validates :value, presence: true
  validates :actual, inclusion: [true, false]
end
