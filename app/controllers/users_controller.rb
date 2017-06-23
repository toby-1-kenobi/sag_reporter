class UsersController < ApplicationController

  include ParamsHelper

  before_action :require_login, except: [:show_external, :index_external, :confirm_email]
  before_action :authenticate, only: [:show_external, :index_external]

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

  def show_external
    user_data = Hash.new
    user_data['id'] = current_user.id
    user_data['geo_states'] = Array.new
    current_user.geo_states.includes(:state_languages).each do |gs|
      languages = Array.new
      gs.state_languages.in_project.each do |sl|
        languages << {
            'id' => sl.id,
            'language_name' => sl.language_name
        }
      end
      user_data['geo_states'] << {
          'id' => gs.id,
          'name' => gs.name,
          'languages' => languages
      }
    end
    render json: user_data
  end

  def index_external
    user_data = Array.new
    User.all.each do |user|
      user_specific_data = {
          'id' => user.id,
          'name' => user.name
      }
      user_data << user_specific_data
    end
    render json: {'users' => user_data}
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
      if user_factory.instance()
        logger.debug(user_factory.instance().errors.full_messages)
        @user = user_factory.instance()
      else
        logger.error('no instance in user factory when creating a user failed')
        flash[:error] = 'Something went wrong with creating the user. Sorry'
        @user = User.new
      end
      assign_for_user_form
      render 'new'
    end
  end

  def edit
  end

  def update
    updater = User::Updater.new(@user)
    message = 'Profile updated'
    if updater.update_user(user_params)
      if updater.instance.confirm_token.present?
        message = 'Profile updated with email. Please check mail and confirm your email.'
      end
      flash['success'] = message
      redirect_to @user
    else
      @user = updater.instance()
      assign_for_user_form
      render 'edit'
    end
  end

  def confirm_email
    logger.debug 'validating email address'
    user = User.find_by_confirm_token(params[:id])
    if user
      # Allow email to be confirmed if the user is logged in
      # or half logged in (authenticated but not OTP received)
      if logged_in_user?(user) or session[:temp_user] == user.id
        user.email_activate
        flash[:success] = 'Your email address has been validated.'
      else
        log_out if logged_in?
        flash[:error] = "You must be logged in as #{user.name} to validate that email address"
      end
    else
      flash[:error] = 'Your email validation token is not valid. Try resending the email confirmation.'
    end
    redirect_to root_path
  end

  def re_confirm_email
    if current_user.resend_email_token
      UserMailer.user_email_confirmation(current_user).deliver_now
      render json: {success: true, message: 'Confirmation email sent to your email address!'}
    else
      render json: {success: false, message: 'Ooops Something went wrong. Please try later'}
    end
  end

  def destroy
    name = @user.name
    if @user.destroy
      flash[:success] = "User #{name} deleted"
    else
      flash[:error] = "Unable to delete #{name}"
      flash[:error] += ': '+ @user.errors.messages.values.join(', ') if @user.errors.any?
    end
    redirect_to users_url
  end

  private

    def user_params
      # make hash options into arrays
      param_reduce(params['user'], ['geo_states', 'speaks', 'curated_states'])
      safe_params = [
        :name,
        :phone,
        :password,
        :password_confirmation,
        :email,
        :email_confirmed,
        :confirm_token,
        :mother_tongue_id,
        :interface_language_id,
        :trusted,
        :admin,
        :national,
        :role_description,
        {:speaks => []},
        {:geo_states => []},
        {:curated_states => []}
      ]
      # current user cannot change own access level or state
      if params[:id] and logged_in_user?(User.find(params[:id]))
        safe_params.reject!{ |p| [:admin].include? p }
        # but admin user can change his own state and curated states
        safe_params.reject!{ |p|
          p == {:geo_states => []} || p == {:curated_states => []} || [:trusted, :national].include?(p)
        } unless logged_in_user.admin?
      end
      params.require(:user).permit(safe_params)
    end

    def assign_for_user_form
      @roles = Role.all
      @languages = Language.includes(:geo_states).order(:name)
      @interface_languages = Language.where.not(locale_tag: nil).order(:name)
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
