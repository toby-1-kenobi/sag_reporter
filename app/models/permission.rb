class Permission < ActiveRecord::Base

	has_many :role_relationships, class_name: "RolesPermission", dependent: :destroy
	has_many :roles, through: :role_relationships
	validates :name, presence: true, allow_nil: false
	
end
