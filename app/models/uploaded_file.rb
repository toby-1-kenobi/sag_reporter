class UploadedFile < ActiveRecord::Base

  belongs_to :report, inverse_of: :pictures
  mount_uploader :ref, PictureUploader
  validates :ref, presence: true
  validate :file_size

  private

  # Validates the size of an uploaded file.
  def file_size
    if ref.size > 5.megabytes
      errors.add(:ref, "should be less than 5MB")
    end
  end

end
