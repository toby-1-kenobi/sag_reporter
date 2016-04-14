module RolesHelper
  
    # Confirms permissions.
    def permitted_action (permission_names)
      # if the users permissions do not instersect with those given then redirect to root
      redirect_to(root_url) if (permission_names & logged_in_user.permissions.map(&:name)).empty?
    end

end
