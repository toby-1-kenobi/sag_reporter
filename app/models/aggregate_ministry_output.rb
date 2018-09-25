class AggregateMinistryOutput < ActiveRecord::Base

  belongs_to :deliverable
  belongs_to :state_language
  belongs_to :creator, class_name: 'User'

  validates :deliverable, presence: true
  validates :state_language, presence: true
  validates :creator, presence: true
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'"}
  validates :value, presence: true
  validates :actual, inclusion: [true, false]
  validate :deliverable_is_not_for_church_team_assessment
  validate :year_in_range
  validate :month_in_range

  private

  def deliverable_is_not_for_church_team_assessment
    errors.add(:deliverable, 'should not be for church team assessment') if deliverable.church_team?
  end

  def year_in_range
    # valid year range starts at 2018 (the year this was implemented)
    # and goes until 50 years beyond the current year
    # This is purely a sanity check
    year = month[0..3].to_i
    errors.add(:month, "can't be that far in the past") unless year >= 2018
    errors.add(:month, "can't be that far in the future") unless year <= Date.today.year + 50
  end

  def month_in_range
    month_int = month[5..6].to_i
    errors.add(:month, "out of range") unless month_int >=1 and month_int <= 12
  end

end
