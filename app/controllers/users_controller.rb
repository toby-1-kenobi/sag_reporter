class UsersController < ApplicationController

  before_action :require_login
  
  # A user's profile can only be edited by themselves or their supervisor or an admin
  before_action :authorised_user, only: [:edit, :update]

  # Only an admin user can add more users
  #before_action :admin_user, only: [:new, :create]

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
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

  private

    def user_params
      params.require(:user).permit(:name, :phone, :password, :password_confirmation)
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
          current_user?(@user)
      #    or @user.supervisor?(current_user)
      #    or current_user.admin?
    end

    # Confirms admin user.
    def admin_user
      @user = User.find(params[:id])
      #redirect_to(root_url) unless @user.admin?
    end

end
