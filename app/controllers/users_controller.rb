class UsersController < ApplicationController

  include ParamsHelper

  before_action :require_login, except: [:me]
  before_action :authenticate, only: [:me]
  
  # A user's profile can only be edited or seen by
  #    themselves or
  #    their supervisor or
  #    someone with permission
  before_action :authorised_user_edit, only: [:edit, :update]
  before_action :authorised_user_show, only: [:show]

  before_action :assign_for_user_form, only: [:new, :edit]
  before_action :get_param_user, only: [:edit, :update, :destroy]


  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_user?
  end

  before_action only: [:destroy] do
    redirect_to root_path unless logged_in_user.can_delete_user?
  end

  before_action only: [:index] do
    redirect_to root_path unless logged_in_user.can_view_all_users?
  end

  def me
    user_data = Hash.new
    user_data[:name] = current_user.name
    render json: user_data
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  end

  def index
  	@users = User.order('LOWER(name)').paginate(page: params[:page])
  end

  def create
    user_factory = User::Factory.new
    if user_factory.create_user(user_params)
      flash['success'] = 'New User Created!'
      redirect_to user_factory.instance()
    else
      assign_for_user_form
      @user = user_factory.instance()
      render 'new'
    end
  end

  def edit
  end

  def update
    updater = User::Updater.new(@user)
    if updater.update_user(user_params)
      flash['success'] = 'Profile updated'
      redirect_to @user
    else
      @user = updater.instance()
      assign_for_user_form
      render 'edit'
    end
  end

  def destroy
    @name = @user.name
    @user.destroy
    flash[:success] = "User #{@name} deleted"
    redirect_to users_url
  end

  private

    def user_params
      # make hash options into arrays
      param_reduce(params['user'], ['geo_states', 'speaks'])
      safe_params = [
        :name,
        :phone,
        :password,
        :password_confirmation,
        :mother_tongue_id,
        :interface_language_id,
        :role_id,
        {:speaks => []},
        {:geo_states => []}
      ]
      # current user cannot change own role or state
      if params[:id] and logged_in_user?(User.find(params[:id]))
        safe_params.reject!{ |p| p == :role_id }
        # but admin user can change his own state
        safe_params.reject!{ |p| p == {:geo_states => []} } unless logged_in_user.is_an_admin?
      end
      params.require(:user).permit(safe_params)
    end

    def assign_for_user_form
      @roles = Role.all
      @languages = Language.order(:name)
      @interface_languages = Language.where(interface: true).order(:name)
      @geo_states = GeoState.includes(:languages).where.not('languages.id' => nil).order(:name)
      @zones = Zone.order(:name)
    end

    # Confirms authorised user for edit.
    def authorised_user_edit
      get_param_user
      redirect_to(root_url) unless 
          logged_in_user?(@user) or logged_in_user.can_edit_user?
      #    or @user.supervisor?(logged_in_user)
    end

    # Confirms authorised user for show.
    def authorised_user_show
      get_param_user
      redirect_to(root_url) unless 
          logged_in_user?(@user) or logged_in_user.can_view_all_users?
      #    or @user.supervisor?(logged_in_user)
    end

    def get_param_user
      @user = User.find(params[:id])
    end

end
