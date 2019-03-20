class SignOfTransformation < ActiveRecord::Base
  belongs_to :church_ministry
  belongs_to :progress_marker

  validate :progress_marker_xor_other

  private

  def progress_marker_xor_other
    unless !progress_marker_id ^ !other
      errors.add(:base, "Needs either progress marker or other field to be not nil")
    end
  end
end
