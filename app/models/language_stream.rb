class LanguageStream < ActiveRecord::Base
  belongs_to :ministry
  belongs_to :state_language
  belongs_to :facilitator, class_name: 'User'
  belongs_to :project
  validates :ministry, presence: true
  validates :state_language, presence: true
end
