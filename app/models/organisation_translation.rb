class OrganisationTranslation < ActiveRecord::Base
  belongs_to :language, inverse_of: :organisation_translations
  belongs_to :organisation, inverse_of: :language_translations
  validates :language, presence: true, uniqueness: { scope: :organisation }
  validates :organisation, presence: true
end
