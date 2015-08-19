class Permission < ActiveRecord::Base

	enum category: [ :users, :roles, :languages, :topics, :reports, :tallies, :events, :people, :outputs ]

	has_and_belongs_to_many :roles
	validates :name, presence: true, allow_nil: false, uniqueness: true
	
end
