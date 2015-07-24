class Report < ActiveRecord::Base

	enum report_type: [ :hope, :event, :impact ]
	enum state: [ :archived, :active ]

	belongs_to :reporter, class_name: 'User'
	has_and_belongs_to_many :languages
	has_and_belongs_to_many :topics
	validates :content, presence: true, allow_nil: false

end
