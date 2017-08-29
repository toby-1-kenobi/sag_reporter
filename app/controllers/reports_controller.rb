class ReportsController < ApplicationController

  helper ColoursHelper
  include ParamsHelper

  skip_before_action :verify_authenticity_token, only: [:create_external]
  before_action :require_login, except: [:create_external]
  before_action :authenticate, only: [:create_external]

    # Let only permitted users do some things
  before_action only: [:by_language, :by_topic, :by_reporter] do
    redirect_to root_path unless logged_in_user.national?
  end

  before_action only: [:by_reporter, :spreadsheet] do
    redirect_to root_path unless logged_in_user.trusted?
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless logged_in_user.admin?
  end

  before_action :get_translations, only: [:new, :edit]
  before_action :find_report, only: [:edit, :update, :show, :archive, :unarchive, :pictures]

  before_action only: [:show] do
    redirect_to root_path unless logged_in_user.national? or logged_in_user.geo_states.include? @report.geo_state
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

  # new report submitted by an external client
  def create_external
    # convert image-strings to image-files
    base64_data = params['report']['pictures_attributes']
    tempfile = []
    base64_data.each do |image_number, image_data|
      filename = "upload-image" + image_number
      tempfile[image_number.to_i] = Tempfile.new(filename)
      tempfile[image_number.to_i].binmode
      tempfile[image_number.to_i].write Base64.decode64(image_data["data"])
      tempfile[image_number.to_i].rewind
      # for security we want the actual content type, not just what was passed in
      content_type = `file --mime -b #{tempfile[image_number.to_i].path}`.split(";")[0]

      # we will also add the extension ourselves based on the above
      # if it's not gif/jpeg/png, it will fail the validation in the upload model
      extension = content_type.match(/gif|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      params['report']['pictures_attributes'][image_number]['ref'] = ActionDispatch::Http::UploadedFile.new({
        tempfile: tempfile[image_number.to_i],
        content_type: content_type,
        filename: filename
      })
    end
    # create report
    full_params = report_params.merge({reporter: current_user})
    puts full_params
    report_factory = Report::Factory.new
    response = Hash.new
    if report_factory.create_report(full_params)
      response['success'] = true
      response['report_id'] = report_factory.instance.id
    else
      response['success'] = false
      response['errors'] = Array.new
      if report_factory.instance
        response['errors'].concat report_factory.instance.errors.full_messages
      end
      if report_factory.error
        response['errors'] << report_factory.error.message
      end
    end
    puts response.to_json
    render json: response
    # delete tempfile[image_number.to_i] afterwards
  ensure
    tempfile.each do |tmp|
      if tmp
        tmp.close
        tmp.unlink
      end
    end
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
    # if no since date is provided assume 3 months
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    @filters = report_filter_params
    reports = Report.user_limited(logged_in_user).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)
    respond_to do |format|
      format.js { render 'reports/update_collection' }
      format.html
    end
  end

  def by_language
    @geo_states = logged_in_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
    @languages = Language.all.order('LOWER(languages.name)')
  end

  def by_topic
    @geo_states = logged_in_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
    @topics = Topic.all
  end

  def by_reporter
    @geo_states = logged_in_user.geo_states
    @reports = Report.where(geo_state: @geo_states).order(:report_date => :desc)
    @impact_reports = ImpactReport.where(geo_state: @geo_states).order(:report_date => :desc)
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
    current_user = logged_in_user || current_user
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
    safe_params.delete :status unless current_user.admin?
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

  def report_filter_params
    params.permit(
        :archived,
        :significant,
        :since,
        {:types => []},
        :report_types,
        :translation_impact
    )
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
