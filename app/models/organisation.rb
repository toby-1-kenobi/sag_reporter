class Organisation < ActiveRecord::Base
  belongs_to :parent, class_name: 'Organisation', inverse_of: :children
  has_many :children, class_name: 'Organisation', inverse_of: :parent
  has_many :language_engagements, class_name: 'OrganisationEngagement'
  has_many :engaged_languages, through: :language_engagements, source: :language
  has_many :language_translations, class_name: 'OrganisationTranslation'
  has_many :translating_languages, through: :language_translations, source: :language
  has_many :church_teams, dependent: :nullify
  validates :name, presence: true, allow_blank: false, allow_nil: false, uniqueness: true
  validates :abbreviation, uniqueness: true, allow_nil: true

  # return the name with abbreviation if it's present and different from the name
  def name_with_abbr
    if abbreviation.present? and abbreviation != name
      "#{name} (#{abbreviation})"
    else
      name
    end
  end

  # return the name with abbreviation if the given user is trusted otherwise just the id
  def name_with_abbr_or_not(user)
    if user.trusted?
      name_with_abbr
    else
      "Organisation ##{id}"
    end
  end

  def to_s
    name
  end

end
