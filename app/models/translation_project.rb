class TranslationProject < ActiveRecord::Base
  belongs_to :language
  validates :language_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :language_id}
end
