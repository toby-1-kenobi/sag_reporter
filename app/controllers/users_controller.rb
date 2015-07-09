class UsersController < ApplicationController

  before_action :require_login
  
  # A user's profile can only be edited by themselves or their supervisor or an admin
  before_action :authorised_user, only: [:edit, :update]

  # Only an admin user can add more users
  #before_action :admin_user, only: [:new, :create, :destroy]

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

    # Confirms authorised user.
    def authorised_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless 
          current_user?(@user) or current_user.can_edit_user?
        
      #    or @user.supervisor?(current_user)
    end

    # Confirms admin user.
    def admin_user
      @user = User.find(params[:id])
      #redirect_to(root_url) unless @user.admin?
    end

end
