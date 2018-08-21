class LanguageUser < ActiveRecord::Base
  belongs_to :language
  belongs_to :user
  validates :language, presence: true
  validates :user, presence: true
end
