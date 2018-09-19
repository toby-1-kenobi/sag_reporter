class LanguageStream < ActiveRecord::Base
  belongs_to :ministry
  belongs_to :state_language
  belongs_to :facilitator, class_name: 'User'
  belongs_to :project
  has_many :aggregate_ministry_outputs, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :state_language, presence: true
end
