class RolesController < ApplicationController

  def index
  	@roles = Role.all
  	@perms = Permission.all
  end

  def update
  	# parameters come as a hash with role names as keys
  	# and a hash of permissions as values. Each key in the permissions hash
  	# is a permission that should be in that role. No other permission should be.
  	# So for each role clear the permissions, then add permissions
  	# from the keys of the inner hash.
  	params['roles'].each_pair do |role_name, permissions|
  	  role = Role.find_by_name(role_name)
  	  role.permissions.clear
  	  permissions.each_key do |perm_name|
  	  	role.permissions << Permission.find_by_name(perm_name)
  	  end
  	end
  	flash["success"] = 'Roles updated.'
  	redirect_to roles_url	
  end

  def create
  	# insert code to create new role.
  	redirect_to roles_url
  end

end
