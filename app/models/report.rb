class Report < ActiveRecord::Base

	enum type: [ :hope, :event, :impact ]
	enum state: [ :archived, :active ]

end
