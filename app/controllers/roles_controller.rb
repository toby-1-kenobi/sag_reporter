class RolesController < ApplicationController

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_role?
  end
  
  before_action only: [:index] do
    redirect_to root_path unless logged_in_user.can_view_roles?
  end
  
  before_action only: [:update] do
    redirect_to root_path unless logged_in_user.can_edit_role?
  end

  def index
  	@roles = Role.all
  	@permissions = Permission.all
  	@new_role = Role.new
  end

  def update
  	# parameters come as a hash with role names as keys
  	# and a hash of permissions as values. Each key in the permissions hash
  	# is a permission that should be in that role. No other permission should be.
  	# So for each role clear the permissions, then add permissions
  	# from the keys of the inner hash.
    Role.all.each do |role|
      role.permissions.clear
    end
  	params['roles'].each_pair do |role_name, permissions|
  	  role = Role.find_by_name(role_name)
  	  permissions.each_key do |perm_name|
  	  	role.permissions << Permission.find_by_name(perm_name)
  	  end
  	end

		# admin should never loose permission to view and edit roles
    if admin_role = Role.find_by_name('admin')
      admin_role.permissions << Permission.find_by_name('view_roles') << Permission.find_by_name('edit_role')
    else
      flash['warning'] = "It's best to have a role named 'admin' for administrative users."
    end

  	flash['success'] = 'Roles updated.'
  	redirect_to roles_url	
  end

  def create
  	unless params['role'].empty?
      @role = Role.new(role_params)
      if @role.save
        flash['success'] = 'Role ' + @role.name + ' Created.'
      else
        flash['error'] = 'Failed to create role: ' + @role.name
      end
    end
  	redirect_to roles_url
  end

  private

    def role_params
      params.require(:role).permit(:name)
    end

end
