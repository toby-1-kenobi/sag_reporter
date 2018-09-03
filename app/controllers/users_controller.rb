require 'securerandom'
class UsersController < ApplicationController

  include ParamsHelper
  include ReportFilter
  include UsersHelper

  before_action :require_login, except: [:create_registration]

  # A user's profile can only be edited or seen by
  #    themselves or
  #    someone with permission
  before_action :authorised_user_edit, only: [:edit, :update]
  before_action :authorised_user_show, only: [:show]
  before_action :authorised_user_curate, only: [:user_registration_approval, :zone_curator_accept, :zone_curator_reject]

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

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  end

  def index
  	@users = User.approved.order('LOWER(name)').paginate(page: params[:page])
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

  def create_registration
    user_factory = User::Factory.new
    registration_params = user_params
    registration_params[:registration_status] = 0
    tmp_password = SecureRandom.hex
    registration_params[:password] = tmp_password
    registration_params[:password_confirmation] = tmp_password
    user_factory.build_user(registration_params)
    @user = user_factory.instance
    if (Rails.env.development? or verify_recaptcha(modal: @user)) and @user.save
      user_registration_request_mail(@user.zones)
      flash[:success] = "When your registration is approved you will receive further instructions"
      render 'sessions/new'
    else
      @geo_states = GeoState.all.order(:name)
      render 'sessions/sign_up'
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
      if @user.approved?
        redirect_to @user
      else
        redirect_to user_approval_path
      end
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

  def user_registration_approval
    @registrations = {}
    @registrations['new'] = User.unapproved.in_zones(logged_in_user.zones)
    @registrations['zone approved'] = logged_in_user.lci_board_member? ? User.zone_approved : User.none
  end

  def zone_curator_accept
    @user = User.find params[:id]
    if @user
      name = @user.name
      if @user.registration_approval_step(logged_in_user)
        email_send_to_lci_board_members() if @user.zone_approved?
        @success = true
      else
        @success = false
        Rails.logger.error "User #{name} not able to approve"
      end
    else
      @success = false
      Rails.logger.error = "User registration not found for id #{params[:id]}"
    end
    respond_to :js
  end

  def zone_curator_reject
    user = User.find params[:id]
    name = user.name
    @user_id = user.id #backup user id to remove row in html page
    if user.destroy
      @success = true
    else
      @success = false
      Rails.logger.error "Unable to delete registration for #{name}"
      Rails.logger.error user.errors.full_messages if user.errors.any?
    end
    respond_to :js
  end

  def generate_pwd_reset_token_user(user)
    token = User.new_token
    @user = User.find_by(id: user.id)
    if @user
      @user.update_attributes(reset_password_token: BCrypt::Password.create(token))
      return token
    else
      return false
    end
  end

  private

  def user_params
    # make hash options into arrays
    param_reduce(params['user'], ['projects', 'geo_states', 'champion', 'speaks', 'curated_states'])
    safe_params = [
      :name,
      :phone,
      :password,
      :password_confirmation,
      :email,
      :email_confirmed,
      :confirm_token,
      :interface_language_id,
      :training_level,
      :trusted,
      :admin,
      :national,
      :role_description,
      {:projects => []},
      {:champion => []},
      {:speaks => []},
      {:geo_states => []},
      {:curated_states => []},
      :reset_password,
      :registration_curator
    ]
    # current user cannot change own access level or state
    if params[:id] and logged_in_user?(User.find(params[:id]))
      safe_params.reject!{ |p| [:admin].include? p }
      # but admin user can change his own state and curated states
      safe_params.reject!{ |p|
        p == {:geo_states => []} ||
            p == {:curated_states => []} ||
            p == {:projects => []} ||
            [:trusted, :national, :training_level].include?(p)
      } unless logged_in_user.admin? or logged_in_user.registration_curator?
    end
    params.require(:user).permit(safe_params)
  end

  def assign_for_user_form
    @languages = Language.includes(:geo_states).order(:name)
    @interface_languages = Language.where.not(locale_tag: nil).order(:name)
    @geo_states = GeoState.includes(:languages).where.not('languages.id' => nil).order(:name)
    @zones = Zone.order(:name)
    @projects = Project.order(:name)
  end

  # Confirms authorised user for edit.
  def authorised_user_edit
    get_param_user
    redirect_to(root_url) unless
        logged_in_user?(@user) or
            logged_in_user.admin? or
            logged_in_user.lci_board_member? or
            (logged_in_user.registration_curator? and (@user.zones & logged_in_user.zones).any?)
  end

  # Confirms authorised user for show.
  def authorised_user_show
    get_param_user
    redirect_to(root_url) unless
        logged_in_user?(@user) or logged_in_user.admin?
  end

  def authorised_user_curate
    redirect_to(root_url) unless
            logged_in_user.admin? or
            logged_in_user.lci_board_member? or
            logged_in_user.registration_curator?
  end

  def get_param_user
    @user = User.find(params[:id])
  end

  def user_registration_request_mail(zones)
    zones.each do |zone|
      curators = User.includes(:geo_states).where(registration_curator: true, geo_states: {zone_id: zone.id})
      curators.each do |curator|
        if curator.email.present?
          logger.debug "sending registration request to email: #{curator.email}"
          UserMailer.registration_request_email(curator).deliver_now
          true
        end
      end
    end
  end

  def email_send_to_lci_board_members()
    lci_board_members = User.where(lci_board_member: true)
    lci_board_members.each do |board_member|
      if board_member.email.present?
        logger.debug "sending registered user information to email: #{board_member.email}"
        UserMailer.send_email_to_lci_board_members(board_member).deliver_now
      end
    end
  end

end
