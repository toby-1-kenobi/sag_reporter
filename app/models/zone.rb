class Zone < ActiveRecord::Base

  has_many :geo_states
  has_many :users, through: :geo_states

  def self.of_states(geo_states)
    geo_states.collect{ |gs| gs.zone }.uniq
  end

end
