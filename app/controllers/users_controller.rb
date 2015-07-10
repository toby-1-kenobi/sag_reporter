class UsersController < ApplicationController

  before_action :require_login
  
  # A user's profile can only be edited or seen by
  #    themselves or
  #    their supervisor or
  #    someone with permission
  before_action :authorised_user_edit, only: [:edit, :update]
  before_action :authorised_user_show, only: [:show]

  # Let only permitted users do some things
  before_action only: [:new, :create] do
    permitted_user ['create_user'] 
  end

  before_action only: [:destroy] do
    permitted_user ['delete_user']
  end
  
  before_action only: [:index] do
    permitted_user ['view_all_users']
  end

  def new
  	@user = User.new
    @roles = Role.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def index
  	@users = User.paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash["success"] = "New User Created!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash["success"] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
  	@user = User.find(params[:id])
    @name = @user.name
    @user.destroy
    flash[:success] = "User #{@name} deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :phone, :password, :password_confirmation, :role_id)
    end

    # Confirms a logged-in user.
    def require_login
      unless logged_in?
      	store_location
        flash["warning"] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms authorised user for edit.
    def authorised_user_edit
      @user = User.find(params[:id])
      redirect_to(root_url) unless 
          current_user?(@user) or current_user.can_edit_user?
      #    or @user.supervisor?(current_user)
    end

    # Confirms authorised user for show.
    def authorised_user_show
      @user = User.find(params[:id])
      redirect_to(root_url) unless 
          current_user?(@user) or current_user.can_view_all_users?
      #    or @user.supervisor?(current_user)
    end

    # Confirms permissions.
    def permitted_user (permission_names)
      # if the users permissions do not instersect with those given then redirect to root
      redirect_to(root_url) if (permission_names & current_user.permissions.map(&:name)).empty?
    end

end
