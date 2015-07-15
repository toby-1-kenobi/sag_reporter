class Permission < ActiveRecord::Base

	has_and_belongs_to_many :roles
	validates :name, presence: true, allow_nil: false, uniqueness: true
	
end
