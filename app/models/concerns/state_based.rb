module StateBased

  extend ActiveSupport::Concern

  included do
    belongs_to :geo_state
    validates :geo_state, presence: true
  end

  # if a given user is editing the object, what geo_states are
  # available to them to assign?
  # It is their own geo_states plus the one already assigned
  def available_geo_states(user)
    available = user.geo_states.to_a
    if self.geo_state
      available << self.geo_state
      available.uniq!
    end
    return available
  end

end