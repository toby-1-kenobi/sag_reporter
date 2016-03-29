module LocationBased

  extend ActiveSupport::Concern

  include StateBased

  included do
    belongs_to :sub_district
    delegate :district, to: :sub_district
    validate :location_must_be_in_geo_state
  end

  private

  def geo_state_init
    self.geo_state ||= sub_district ? sub_district.geo_state : nil
    super
  end

  def location_must_be_in_geo_state
    if sub_district and sub_district.geo_state != geo_state
      errors.add(:sub_district, "is not located within the #{geo_state.name}")
    end
  end

  def location_present_for_new_record
    if new_record? and sub_district.blank?
      errors.add(:sub_district, "must be valid.")
    end
  end

end