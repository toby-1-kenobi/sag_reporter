class Language < ActiveRecord::Base

	validates :name, presence: true, allow_nil: false, uniqueness: true
	
end