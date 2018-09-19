class Deliverable < ActiveRecord::Base
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :quarterly_targets, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :number, presence: true, uniqueness: { scope: :ministry }
end
