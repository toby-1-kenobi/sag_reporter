class UploadedFile < ActiveRecord::Base
  belongs_to :report, inverse_of: :pictures
  mount_uploader :ref, PictureUploader
  validates :ref, presence: true
end
