class LanguagesTally < ActiveRecord::Base
  belongs_to :language
  belongs_to :tally
end
