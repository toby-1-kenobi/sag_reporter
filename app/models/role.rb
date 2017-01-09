class Role < ActiveRecord::Base

	has_many :users, dependent: :restrict_with_error
	has_and_belongs_to_many :permissions
	validates :name, presence: true, allow_nil: false, uniqueness: true

end
