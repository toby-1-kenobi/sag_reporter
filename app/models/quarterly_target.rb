class QuarterlyTarget < ActiveRecord::Base

  has_paper_trail

  belongs_to :state_language
  belongs_to :deliverable

  validates :state_language, presence: true
  validates :deliverable, presence: true, uniqueness: { scope: [:quarter, :state_language] }
  validates :quarter, presence: true, format: { with: /\A[2-9]\d{3}-[1-4]\z/, message: "should be in the format 'YYYY-Q'" }
  validates :value, presence: true

  scope :year, -> (year){ where('quarter LIKE ?', "%#{year}-%") }

  def year
    quarter.slice(0..3).to_i
  end

end
