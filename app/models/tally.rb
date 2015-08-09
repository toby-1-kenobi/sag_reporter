class Tally < ActiveRecord::Base

	enum state: [ :archived, :active ]

	belongs_to :topic
	has_many :language_tallies, class_name: 'LanguagesTally', dependant: :destroy
	has_many :languages, through: :language_tallies
	has_many :tally_updates, through: :language_tallies
	
end
