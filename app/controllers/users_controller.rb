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
    redirect_to root_path unless current_user.can_create_user?
  end

  before_action only: [:destroy] do
    redirect_to root_path unless current_user.can_delete_user?
  end

  before_action only: [:index] do
    redirect_to root_path unless current_user.can_view_all_users?
  end

  def new
  	@user = User.new
    @roles = Role.all
    @languages = Language.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def index
  	@users = User.order("LOWER(name)").paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if params['speaks']
        params['speaks'].each do |lang_id_arr|
          @user.spoken_languages << Language.find_by_id(lang_id_arr.first.to_i)
        end
      end
      flash["success"] = "New User Created!"
      redirect_to @user
    else
      @roles = Role.all
      @languages = Language.all
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    @languages = Language.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @user.spoken_languages.clear
      if params['speaks']
        params['speaks'].each do |lang_id_arr|
          @user.spoken_languages << Language.find_by_id(lang_id_arr.first.to_i)
        end
      end
      flash["success"] = "Profile updated"
      redirect_to @user
    else
      @roles = Role.all
      @languages = Language.all
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
      # current user cannot change own role
      if params[:id] and current_user?(User.find(params[:id]))
        params.require(:user).permit(
          :name,
          :phone,
          :password,
          :password_confirmation,
          :mother_tongue_id
        )
      else
        params.require(:user).permit(
          :name,
          :phone,
          :password,
          :password_confirmation,
          :mother_tongue_id,
          :role_id
        )
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

end
