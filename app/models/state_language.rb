class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language

  validates :geo_state, presence: true
  validates :language, presence: true

end
