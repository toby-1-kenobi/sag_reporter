class RolesController < ApplicationController

  def index
  	@roles = Role.all
  	@perms = Permission.all
  end

  def update
  	# insert code to update roles.
  	redirect_to roles_url
  end

  def create
  	# insert code to create new role.
  	redirect_to roles_url
  end

end
