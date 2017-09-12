class UsersController < ApplicationController

  include ParamsHelper
  include ReportFilter

  # A user's profile can only be edited or seen by
  #    themselves or
  #    someone with permission
  before_action :authorised_user_edit, only: [:edit, :update]
  before_action :authorised_user_show, only: [:show]

  before_action :assign_for_user_form, only: [:new, :edit]
  before_action :get_param_user, only: [:edit, :update, :destroy]


  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action only: [:destroy] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action only: [:index] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action :require_login, except: [:confirm_email, :show_external, :index_external]
  # methods related to an external client (=android app)
  skip_before_action :verify_authenticity_token, only: [:show_external, :index_external]
  before_action :authenticate, only: [:show_external, :index_external]

  # sends user related data (inclusive related states and their languages)
  def show_external
    begin
      last_external_update = params.require(:user).permit(:updated_at)[:updated_at]
      user_data = Hash.new
      user_data[:id] = current_user.id
      user_data[:geo_states] = Array.new
      last_updated = [current_user.updated_at]
      current_user.geo_states.includes(state_languages: :language).where(state_languages: {project: true}).each do |geo_state|
        languages = geo_state.state_languages.map do |state_language|
            last_updated << state_language.updated_at
            {language_id: state_language.language.id,
             language_name: state_language.language_name}
        end
        user_data[:geo_states] << {
            state_id: geo_state.id,
            state_name: geo_state.name,
            languages: languages
        }
        last_updated << geo_state.updated_at
      end
      last_updated = last_updated.max.to_i
      user_data[:updated_at] = last_updated.to_i
      user_data[:status] = "newer"
      if last_updated > last_external_update
        puts user_data
        render json: {user: user_data}, status: :ok
      else
        puts "User data not changed"
        render json: {user: {status: "same"}}, status: :ok
      end
    rescue => e
      puts e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end

  # sends all user_names
  def index_external
    begin
      last_external_update = params.require(:user).permit(:updated_at)[:updated_at]
      user_data = Hash.new
      last_updated = Array.new
      User.all.each do |user|
        user_data[user.id.to_s] = user.name
        last_updated << user.updated_at
      end
      last_updated = last_updated.max.to_i
      user_data[:updated_at] = last_updated.to_i
      user_data[:status] = "newer"
      puts user_data
      if last_updated > last_external_update
        puts user_data
        render json: {user: user_data}, status: :ok
      else
        puts "User data not changed"
        render json: {user: {status: "same"}}, status: :ok
      end
    rescue => e
      puts e
      render json: { error: e.to_s, where: e.backtrace.to_s }, status: :internal_server_error
    end
  end
  # until here methods were related to an external client (=android app)

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
    if user_factory.create_user(user_params, logged_in_user.admin?)
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
    if updater.update_user(user_params, logged_in_user.admin?)
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

  def reports

    # admin users can see the reports of other users
    if params[:id] and logged_in_user.admin?
      get_param_user
    else
      # if no user id passed or current user is not admin then the user sees their own reports
      @user = logged_in_user
    end

    # if no since date is provided assume 3 months
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    params[:until] ||= Date.today.strftime('%d %B, %Y')
    @filters = report_filter_params
    reports = Report.reporter(@user).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)
    respond_to do |format|
      format.html
      format.js { render 'reports/update_collection' }
    end
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
    @languages = Language.includes(:geo_states).order(:name)
    @interface_languages = Language.where.not(locale_tag: nil).order(:name)
    @geo_states = GeoState.includes(:languages).where.not('languages.id' => nil).order(:name)
    @zones = Zone.order(:name)
  end

  # Confirms authorised user for edit.
  def authorised_user_edit
    get_param_user
    redirect_to(root_url) unless
        logged_in_user?(@user) or logged_in_user.admin?
  end

  # Confirms authorised user for show.
  def authorised_user_show
    get_param_user
    redirect_to(root_url) unless
        logged_in_user?(@user) or logged_in_user.admin?
  end

  def get_param_user
    @user = User.find(params[:id])
  end

end
