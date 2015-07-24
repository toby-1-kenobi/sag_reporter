class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  validates :name, presence: true, allow_nil: false, uniqueness: true
  has_and_belongs_to_many :reports
	
end
