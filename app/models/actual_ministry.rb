class ActualMinistry < ActiveRecord::Base
  belongs_to :church_congregation
  belongs_to :ministry_marker

  validates :year, presence: true, inclusion: 2018..Time.now.year
  validates :month, presence: true, inclusion: 1..12
  validates :value, presence: true
end
