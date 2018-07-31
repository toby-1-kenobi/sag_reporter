class MinistryMarker < ActiveRecord::Base
  belongs_to :ministry
  has_many :planned_ministries, dependent: :destroy
  validates :name, presence: true
end
