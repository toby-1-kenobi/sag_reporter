class MinistryMarker < ActiveRecord::Base
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :destroy
  validates :name, presence: true
end
