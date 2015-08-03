class Zone < ActiveRecord::Base

  has_many :geo_states
  has_many :users, through: :geo_states

end
