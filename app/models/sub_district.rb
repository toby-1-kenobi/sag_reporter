class SubDistrict < ActiveRecord::Base

  has_paper_trail

  belongs_to :district
  has_many :reports, dependent: :nullify

  delegate :geo_state, to: :district
  delegate :name, to: :district, prefix: true

  validates :name, presence: true, allow_nil: false, uniqueness: { scope: :district }
  validates :district, presence: true, allow_nil: false
end
