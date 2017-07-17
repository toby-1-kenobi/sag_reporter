class UsersController < ApplicationController

  include ParamsHelper

  before_action :require_login, except: [:me, :confirm_email]
  before_action :authenticate, only: [:me]

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

  def me
    user_data = Hash.new
    user_data['id'] = current_user.id
    user_data['name'] = current_user.name
    user_data['phone'] = current_user.phone
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
    user_data['reports'] = Array.new
    current_user.reports.each do |report|
      if report.impact_report
        language_ids = Array.new
        report.languages.each do |rl|
          language_ids << StateLanguage.find_by(
              geo_state_id: report.geo_state_id, 
              language_id: rl.id, 
              project: true
          ).id
        end
        user_data['reports'] << {
            'report_id' => report.id,
            'geo_state_id' => report.geo_state.id,
            'report_date' => report.report_date,
            'content' => report.content,
            'impact_report' => 1,
            'languages' => language_ids,
            'client' => report.client,
            'version' => report.version
        }
      end
    end
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
    # look for a date, fetching reports since then.
    if params[:since]
      # here we're trusting the parse function will be able to handle whatever format comes its way in this context
      @since_date = Date.parse(params[:since])
    else
      # if no date provided assume 3 months
      @since_date = 3.months.ago
    end
    @reports = Report.reporter(@user).since(@since_date).order(report_date: :desc)
    @archived = params[:archived].present?
    @reports = @reports.active unless @archived
    respond_to do |format|
      format.html
      format.js
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
    end

    # Confirms authorised user for show.
    def authorised_user_show
      get_param_user
      redirect_to(root_url) unless
          logged_in_user?(@user) or logged_in_user.can_view_all_users?
    end

    def get_param_user
      @user = User.find(params[:id])
    end

end
