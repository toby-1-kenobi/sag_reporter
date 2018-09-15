class StateProject < ActiveRecord::Base
  belongs_to :project
  belongs_to :geo_state
  validates :project, presence: true
  validates :geo_state, presence: true
end
