class District < ActiveRecord::Base

  has_paper_trail

  belongs_to :geo_state
  has_many :sub_districts, dependent: :destroy

  validates :name, presence: true, allow_nil: false, uniqueness: { scope: :geo_state }
  validates :geo_state, presence: true, allow_nil: false
  validates :sub_districts, :length => { :minimum => 1 }
end
