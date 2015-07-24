class Topic < ActiveRecord::Base

	has_and_belongs_to_many :reports
	has_many :tallies
	
end
