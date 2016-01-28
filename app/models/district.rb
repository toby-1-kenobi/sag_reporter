class District < ActiveRecord::Base
  belongs_to :geo_state

  validates :name, presence: true, allow_nil: false
  validates :geo_state, presence: true, allow_nil: false
end
