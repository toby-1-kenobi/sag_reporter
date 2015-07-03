class Role < ActiveRecord::Base

	has_many :users
	has_many :permission_relationships, class_name: "RolesPermission", dependent: :destroy
	has_many :permissions, through: :permission_relationships
	validates :name, presence: true, allow_nil: false

end
