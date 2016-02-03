module LocationBased

  extend ActiveSupport::Concern

  included do
    belongs_to :sub_district
    delegate :district, to: :sub_district
    validates :sub_district, presence: 
    validate :location_must_be_in_geo_state
  end

  private

  def geo_state_init
    self.geo_state ||= sub_district.geo_state
    super
  end

  def location_must_be_in_geo_state
    if sub_district.geo_state != geo_state
      errors.add(:sub_district, "must be located within the State")
    end
  end

end