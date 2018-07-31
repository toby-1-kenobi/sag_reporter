class MinistryMarker < ActiveRecord::Base
  belongs_to :ministry
  validates :name, presence: true
end
