class Deliverable < ActiveRecord::Base
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  validates :number, presence: true, uniqueness: true
  validates :for_facilitator, inclusion: [true, false]
end
