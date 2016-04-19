class SubDistrict < ActiveRecord::Base
  belongs_to :district
  has_many :reports, dependent: :nullify
  has_many :events, dependent: :nullify

  delegate :geo_state, to: :district

  validates :name, presence: true, allow_nil: false, uniqueness: { scope: :district }
  validates :district, presence: true, allow_nil: false
end
