class Curating < ActiveRecord::Base
  belongs_to :user
  belongs_to :geo_state
  validates :user, presence: true
  validates :geo_state, presence: true, uniqueness: { scope: :user }
end
