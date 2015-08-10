class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  has_and_belongs_to_many :reports
  has_and_belongs_to_many :impact_reports
  has_many :language_tallies, class_name: 'LanguagesTally'
  has_many :tallies, through: :language_tallies

  validates :name, presence: true, allow_nil: false, uniqueness: true
	
end
