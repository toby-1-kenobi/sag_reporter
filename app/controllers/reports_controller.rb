class ReportsController < ApplicationController

  helper ColoursHelper
  include ParamsHelper
  include ReportFilter

  before_action :require_login

  before_action only: [:spreadsheet] do
    redirect_to root_path unless logged_in_user.trusted?
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action :get_translations, only: [:new, :edit]
  before_action :find_report, only: [:edit, :update, :show, :archive, :unarchive, :pictures]

  before_action only: [:show] do
    if logged_in_user.trusted?
      redirect_to root_path unless logged_in_user.national? or logged_in_user.geo_states.include? @report.geo_state
    else
      redirect_to root_path unless logged_in_user?(@report.reporter)
    end
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.admin? or logged_in_user?(@report.reporter)
  end

  before_action only: [:pictures] do
    head :forbidden unless logged_in_user.trusted? or logged_in_user?(@report.reporter)
  end

  def new
  	@report = Report.new
    # build some things for the nested forms to hang from
    @report.pictures.build
    @report.impact_report = ImpactReport.new
    @geo_states = logged_in_user.geo_states
  	@project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: @geo_states).order('languages.name')
    @topics = Topic.all
  end

  def create
    full_params = report_params.merge({reporter: logged_in_user})
    report_factory = Report::Factory.new
    if report_factory.create_report(full_params)
      flash['success'] = 'Report Submitted!'
      # if the report has been marked as significant and an email entered
      # then send this report to that email (unless it's the reporter's email)
      if report_factory.instance.significant? and params[:supervisor_email].present? and params[:supervisor_email] != report_factory.instance.reporter.email
        # make sure TLS gets used for delivering this email
        if SendGridV3.enforce_tls
          recipient = User.find_by_email params[:supervisor_email]
          recipient ||= params[:supervisor_email]
          delivery_success = false
          begin
            UserMailer.user_report(recipient, report_factory.instance).deliver_now
            delivery_success = true
            flash['success'] = 'Report Submitted and sent to your supervisor!'
          rescue EOFError,
                IOError,
                TimeoutError,
                Errno::ECONNRESET,
                Errno::ECONNABORTED,
                Errno::EPIPE,
                Errno::ETIMEDOUT,
                Net::SMTPAuthenticationError,
                Net::SMTPServerBusy,
                Net::SMTPSyntaxError,
                Net::SMTPUnknownError,
                OpenSSL::SSL::SSLError => e
            flash['error'] = 'Failed to send the report to your supervisor'
            Rails.logger.error e.message
          end
          if delivery_success
            # also send it to the reporter
            UserMailer.user_report(report_factory.instance.reporter, report_factory.instance).deliver_now
          end
        else
          flash['error'] = 'Could not ensure email encryption so didn\'t send the report to your supervisor'
          Rails.logger.error 'Could not enforce TLS with SendGrid'
        end
      end
      redirect_to report_factory.instance
    else
      @report = report_factory.instance
      @report ||= Report.new
      flash['error'] = report_factory.error ? report_factory.error.message : 'Unable to submit report!'
      @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: logged_in_user.geo_states).order('languages.name')
      @topics = Topic.all
      @geo_states = @report.available_geo_states(logged_in_user)
      get_translations
      render 'new'
    end
  end

  def show
  end

  def edit
    @report.pictures.build
    @geo_states = @report.available_geo_states(logged_in_user)
    @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: logged_in_user.geo_states).order('languages.name')
    @topics = Topic.all
  end

  def update
    updater = Report::Updater.new(@report)
  	if updater.update_report(report_params)
      flash['success'] = 'Report Updated!'
      redirect_to @report
    else
      if updater.error
        flash['error'] = "Report update failed: #{updater.error.message}"
      end
      @geo_states = @report.available_geo_states(logged_in_user)
      @project_languages = StateLanguage.in_project.includes(:language, :geo_state).where(geo_state: logged_in_user.geo_states)
      @topics = Topic.all
      get_translations
      render 'edit'
    end
  end

  def index
    # if no dates are provided assume 3 months ago until today
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    params[:until] ||= Date.today.strftime('%d %B, %Y')
    @filters = report_filter_params
    reports = Report.user_limited(logged_in_user).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)

    respond_to do |format|
      format.js { render 'reports/update_collection' }
      format.html {
        # html format means we are just going onto the page, not changing the filters yet
        # if there are more than 100 reports ready, start with only more recent reports
        if @reports.count > 100
          @filters[:since] = 1.month.ago.strftime('%d %B, %Y')
          @reports = @reports.since(1.month.ago)
        end
      }
    end
  end

  def archive
    @report.archived!
    respond_to do |format|
      format.js
      format.html do
        redirect_to @report
      end
    end
  end

  def unarchive
    @report.active!
    respond_to do |format|
      format.js
      format.html do
        redirect_to @report
      end
    end
  end

  def pictures
    respond_to do |format|
      format.js
    end
  end

  def spreadsheet
    # The user can't see reports from geo_states they're not in
    # so take the intersection of the list of geo_states in the params
    # and the users geo_states
    if params['controls']['geo_state']
      geo_states = params['controls']['geo_state'].values.map{ |id| id.to_i } & logged_in_user.geo_states.pluck(:id)
    else
      geo_states = logged_in_user.geo_states
    end
    languages = params['controls']['language'].values.map{ |id| id.to_i }
    # The id that's one more than the biggest id for languages
    # corresponds to the "no language" selection
		languages += [nil] if languages.any?{|language_id| language_id == (Language.order('id').last.try(:id).to_i + 1)}
    @reports = Report.includes(:languages).where(geo_state: geo_states, 'languages.id' => languages)

    if !params['show_archived']
      @reports = @reports.active
    end

    report_types = Array.new
    report_types << params['show_impact'] if params['show_impact']
    report_types << params['show_planning'] if params['show_planning']

    start_date = params['from_date'].to_date
    end_date = params['to_date'].to_date
    @reports = @reports.select do |report|
      # reports after the start date,
      report.report_date >= start_date and
          # before the end date
          report.report_date <= end_date and
          # and have at least one of the selected report types
          (report_types & report.report_type_a).any?
    end

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"impact-reports.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
      end
    end
  end

  private

  def report_params
    # make hash options into arrays
    param_reduce(params['report'], %w(topics languages))
    safe_params = [
      :content,
      :mt_society,
      :mt_church,
      :needs_society,
      :needs_church,
      :geo_state_id,
      :report_date,
      :planning_report,
      :impact_report,
      {:languages => []},
      {:topics => []},
      {:pictures_attributes => [:ref, :_destroy, :id]},
      {:observers_attributes => [:id, :name]},
      {:impact_report_attributes => [:translation_impact]},
      :status,
      :significant,
      :location,
      :sub_district_id,
      :client,
      :version
    ]
    safe_params.delete :status unless logged_in_user.admin?
    # if we have a date try to change it to db-friendly format
    # otherwise set it to nil
    if params[:report][:report_date]
      begin
        params[:report][:report_date] = DateParser.parse_to_db_str(params[:report][:report_date]) unless params[:report][:report_date].empty?
      rescue ArgumentError
        params[:report][:report_date] = nil
      end
    end
    permitted = params.require(:report).permit(safe_params)
  end

  def find_report
    @report = Report.find params[:id]
  end

  def get_translations
    @translations = Hash.new
    if logged_in_user.interface_language
      lang_id = logged_in_user.interface_language.id
      Translatable.includes(:translations).find_each do |translatable|
        translation = translatable.translations.select{ |t| t.language_id == lang_id }.first
        content = (translation and translation.content) ? translation.content : translatable.content
        @translations[translatable.identifier] = content
      end
    else
      Translatable.find_each do |translatable|
        @translations[translatable.identifier] = translatable.content
      end
    end
  end

end
