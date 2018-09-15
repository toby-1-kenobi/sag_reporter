class Deliverable < ActiveRecord::Base
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :quarterly_targets, dependent: :restrict_with_error
  validates :number, presence: true, uniqueness: true
  validates :for_facilitator, inclusion: [true, false]
end
