class Deliverable < ActiveRecord::Base
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  validates :name, presence: true
  validates :for_facilitator, presence: true
end
