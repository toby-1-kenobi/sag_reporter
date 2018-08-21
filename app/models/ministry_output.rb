class MinistryOutput < ActiveRecord::Base

  belongs_to :church_ministry
  belongs_to :ministry_marker
  belongs_to :creator, class_name: "User"

  validates :church_ministry, presence: true
  validates :ministry_marker, presence: true
  validates :creator, presence: true
  validates :year, presence: true, inclusion: 2018..(Time.now.year + 50)
  validates :month, presence: true, inclusion: 1..12
  validates :value, presence: true
  validates :actual, inclusion: [true, false]
  validate :ministry_marker_belongs_to_church_ministry

  private

  def ministry_marker_belongs_to_church_ministry
    errors.add(:ministry_marker, "must belong to the church ministry") unless ministry_marker.ministry == church_ministry.ministry
  end

end
