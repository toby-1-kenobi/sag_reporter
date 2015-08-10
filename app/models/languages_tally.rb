class LanguagesTally < ActiveRecord::Base

  belongs_to :language
  belongs_to :tally
  has_many :tally_updates, dependent: :destroy
  
end
