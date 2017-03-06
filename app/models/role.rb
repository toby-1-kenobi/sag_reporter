class Role < ActiveRecord::Base

	has_many :users, dependent: :restrict_with_error
	validates :name, presence: true, allow_nil: false, uniqueness: true

end
