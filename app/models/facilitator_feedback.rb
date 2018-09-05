class FacilitatorFeedback < ActiveRecord::Base
  belongs_to :church_ministry
  belongs_to :team_member, class_name: 'User', inverse_of: :facilitator_responses

  validates :church_ministry, presence: true
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'"}
  validates :feedback, presence: true
  validate :year_in_range
  validate :month_in_range

  private
  def year_in_range
    # valid year range starts at 2018 (the year this was implemented)
    # and goes until next
    year = month[0..3].to_i
    errors.add(:month, "can't be that far in the past") unless year >= 2018
    errors.add(:month, "can't be that far in the future") unless year <= Date.today.year + 1
  end

  def month_in_range
    month_int = month[5..6].to_i
    errors.add(:month, "out of range") unless month_int >=1 and month_int <= 12
  end
end
