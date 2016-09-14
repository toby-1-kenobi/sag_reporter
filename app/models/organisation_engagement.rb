class OrganisationEngagement < ActiveRecord::Base
  belongs_to :language, inverse_of: :organisation_engagements
  belongs_to :organisation, inverse_of: :language_engagements
  validates :language, presence: true, uniqueness: { scope: :organisation }
  validates :organisation, presence: true
end
