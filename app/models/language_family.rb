class LanguageFamily < ActiveRecord::Base

  has_paper_trail

  has_many :languages, inverse_of: :family, foreign_key: 'family_id', dependent: :nullify
  validates :name, presence: true, allow_nil: false, uniqueness: true

  def to_s
    name
  end
end
