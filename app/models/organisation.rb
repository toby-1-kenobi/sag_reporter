class Organisation < ActiveRecord::Base
  belongs_to :parent, class_name: 'Organisation', inverse_of: :children
  has_many :children, class_name: 'Organisation', inverse_of: :parent
  has_many :language_engagements, class_name: 'OrganisationEngagement'
  has_many :engaged_languages, through: :language_engagements
  has_many :language_translations, class_name: 'OrganisationTranslation'
  has_many :translating_languages, through: :language_translations
  validates :name, presence: true, allow_blank: false, allow_nil: false, uniqueness: true
  validates :abbreviation, uniqueness: true, allow_nil: true
end
