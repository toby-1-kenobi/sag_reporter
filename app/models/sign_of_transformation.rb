class SignOfTransformation < ActiveRecord::Base
  belongs_to :church_ministry
  belongs_to :marker, class_name: 'SignOfTransformationMarker'

  validate :marker_xor_other

  private

  def marker_xor_other
    unless !marker_id ^ !other
      errors.add(:base, "Needs either progress marker or other field to be not nil")
    end
  end
end
