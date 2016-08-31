class LanguageFamily < ActiveRecord::Base
  has_many :languages, inverse_of: :family, foreign_key: 'family_id', dependent: :nullify
  validates :name, presence: true, allow_nil: false, uniqueness: true
end
