class StateLanguage < ActiveRecord::Base
  belongs_to :geo_state
  belongs_to :language
end
