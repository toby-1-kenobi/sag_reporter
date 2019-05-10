class SignOfTransformation < ActiveRecord::Base

  has_paper_trail

  belongs_to :church_ministry
  belongs_to :marker, class_name: 'SignOfTransformationMarker'

  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }
  validate :marker_xor_other

  private

  def marker_xor_other
    unless !marker_id ^ !other
      errors.add(:base, "Needs either progress marker or other field to be not nil")
    end
  end
end
