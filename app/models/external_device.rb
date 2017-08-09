class ExternalDevice < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true, allow_nil: false
  validates :device_id, presence: true, allow_nil: false
  validates :name, presence: true, allow_nil: false

end
