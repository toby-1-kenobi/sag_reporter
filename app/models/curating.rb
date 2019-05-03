class Curating < ActiveRecord::Base

  has_paper_trail

  belongs_to :user
  belongs_to :geo_state
  validates :user, presence: true
  validates :geo_state, presence: true, uniqueness: { scope: :user }
end
