class Zone < ActiveRecord::Base

  enum pm_description_type: {
      default: 0,
      alternate: 1
  }

  has_many :geo_states
  has_many :users, through: :geo_states
  has_many :languages, through: :geo_states
  has_many :state_languages, through: :geo_states

  def self.of_states(geo_states)
    geo_states.collect{ |gs| gs.zone }.uniq
  end

end
