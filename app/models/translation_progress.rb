class TranslationProgress < ActiveRecord::Base
  belongs_to :language
  belongs_to :chapter
  validates :language, presence: true, uniqueness: { scope: :chapter }
  validates :chapter, presence: true
end
