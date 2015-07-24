class Tally < ActiveRecord::Base

	enum state: [ :archived, :active ]

	belongs_to :topic
	
end
