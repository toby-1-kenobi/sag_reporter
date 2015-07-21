class Report < ActiveRecord::Base

	enum type: [ :hope, :event, :impact ]
	enum state: [ :archived, :active ]

	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics
	validates :content, presence: true, allow_nil: false

end
