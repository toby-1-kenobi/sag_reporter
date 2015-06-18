class UsersController < ApplicationController

  before_action :require_login

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
        flash["warning"] = "Please log in."
        redirect_to login_url
      end
    end

end
