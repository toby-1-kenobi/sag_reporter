class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  validates :name, presence: true, allow_nil: false, uniqueness: true
	
end
