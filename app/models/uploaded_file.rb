class UploadedFile < ActiveRecord::Base

  has_paper_trail

  belongs_to :report, inverse_of: :pictures
  mount_uploader :ref, PictureUploader
  validates :ref, presence: true
  validate :file_size

  private

  # Validates the size of an uploaded file.
  def file_size
    if ref.size > 20.megabytes
      errors.add(:ref, 'should be less than 20MB')
    end
  end

end
