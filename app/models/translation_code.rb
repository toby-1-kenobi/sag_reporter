class TranslationCode < ActiveRecord::Base
  has_many :translations, dependent: :destroy
end
