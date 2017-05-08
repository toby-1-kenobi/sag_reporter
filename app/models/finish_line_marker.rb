class FinishLineMarker < ActiveRecord::Base
  validates :name, presence: true
  validates :description, presence: true
  validates :number, presence: true
end
