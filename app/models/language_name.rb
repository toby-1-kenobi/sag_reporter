class LanguageName < ActiveRecord::Base

  has_paper_trail

  belongs_to :language

  validates :name, presence: true
  validates :language_id, presence: true

end
