class TranslationProject < ActiveRecord::Base
  belongs_to :language
  belongs_to :project
  validates :language_id, presence: true
  validates :project_id, presence: true, uniqueness: {scope: :language_id}
end
