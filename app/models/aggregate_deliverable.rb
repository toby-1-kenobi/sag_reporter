class AggregateDeliverable < ActiveRecord::Base
  belongs_to :ministry
  has_many :aggregate_ministry_outputs, dependent: :restrict_with_error
  has_many :aggregate_quarterly_targets, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :number, presence: true
end
