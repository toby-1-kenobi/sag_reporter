class LanguageName < ActiveRecord::Base

  belongs_to :language

  validates :name, presence: true
  validates :language_id, presence: true

end
