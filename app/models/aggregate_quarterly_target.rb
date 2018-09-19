class AggregateQuarterlyTarget < ActiveRecord::Base
  belongs_to :state_language
  belongs_to :aggregate_deliverable
  validates :state_language, presence: true
  validates :aggregate_deliverable, presence: true
  validates :quarter, presence: true, format: { with: /\A[2-9]\d{3}-[1-4]\z/, message: "should be in the format 'YYYY-Q'" }
  validates :value, presence: true
end
