class ReportsController < ApplicationController

  helper ColoursHelper
  include ParamsHelper

  skip_before_action :verify_authenticity_token, only: [:create_external, :update_external, :index_external]
  before_action :require_login, except: [:create_external, :update_external, :index_external]
  before_action :authenticate, only: [:create_external, :update_external, :index_external]

    # Let only permitted users do some things
  before_action only: [:index, :by_language, :by_topic, :by_reporter] do
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

  before_action only: [:index_external] do
    render json: {errors: 'Permission denied'} unless current_user && current_user.national?
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

  # edited report submitted by an external client (=android app)
  
  def update_external
    begin
      additional_params = [:external_updated_at, :external_id]
      external_params = params.require(:report).permit(additional_params)
      updated_at = external_params.delete 'external_updated_at'
      @report = Report.find external_params.delete('external_id')
      
      full_params = report_params.merge({reporter: current_user})
      report_factory = nil
      success = true
      instance_id = -1
      # use state-language IDs (for being converted back to language IDs by the report-factory)
      language_ids = full_params['languages']
      state_id = full_params['geo_state_id']
      full_params['languages'] = StateLanguage.where(language_id: language_ids, geo_state_id: state_id).map{|sl| sl.id}
      # just edit, if user has the right, to do so
      if updated_at > @report.updated_at.to_i and
          (current_user.admin? or current_user == @report.reporter)
        # delete all old image files (for just using new files)
        @report.pictures.each do |picture|
          picture.remove_ref!
          picture.delete
        end
        report_factory = Report::Updater.new(@report)
        success = report_factory.update_report(full_params)
        instance_id = report_factory.instance.id if success
      end

      response = Hash.new
      if success
        response[:success] = true
        response[:report_id] = instance_id
      else
        response[:success] = false
        response[:errors] = Array.new
        if report_factory.instance
          response[:errors].concat report_factory.instance.errors.full_messages
        end
        if report_factory.error
          response[:errors] << report_factory.error.message
        end
      end
      render json: response
    rescue => e
      puts e
      render json: { error: e }
    end
  end
  
  # new report submitted by an external client (=android app)
  def create_external
    begin
      full_params = report_params.merge({reporter: current_user})
      report_factory = nil
      success = true
      instance_id = -1
      # use state-language IDs (for being converted back to language IDs by the report-factory)
      language_ids = full_params['languages']
      state_id = full_params['geo_state_id']
      full_params['languages'] = StateLanguage.where(language_id: language_ids, geo_state_id: state_id).map{|sl| sl.id}
      
      report_factory = Report::Factory.new
      success = report_factory.create_report(full_params)
      instance_id = report_factory.instance.id if success

      response = Hash.new
      if success
        response[:success] = true
        response[:report_id] = instance_id
      else
        response[:success] = false
        response[:errors] = Array.new
        if report_factory.instance
          response[:errors].concat report_factory.instance.errors.full_messages
        end
        if report_factory.error
          response[:errors] << report_factory.error.message
        end
      end
      render json: response
    rescue => e
      puts e
      render json: { error: e }
    end
  end

  # send all reports to an external client (=android app)
  def index_external
    begin
      external_params = !params[:reports].nil? && !params[:reports].empty? &&
          params.permit(reports: [:id, :updated_at])[:reports]
      report_data = Array.new
      user_geo_states = current_user.geo_states.ids
      Report.includes(:languages, :pictures).where.not(impact_report: nil).each do |report|

        next unless user_geo_states.include? report.geo_state_id

        language_ids = report.languages.map {|language| language.id}

        pictures = Hash.new
        report.pictures.each do |picture|
          if picture.ref.file.exists?
            picture_id = picture[:id]
            file_content = Base64.encode64 picture.ref.read
            pictures[picture_id] = file_content
          end
        end

        if external_params && external_params[report.id.to_s]
          if report.updated_at.to_i == external_params[report.id.to_s][:updated_at]
            report_data << {id: report.id, updated_at: 0}
            next
          end
          if report.updated_at.to_i < external_params[report.id.to_s][:updated_at]
            report_data << {id: report.id, updated_at: -1}
            next
          end
        end
        report_data << {
            id: report.id,
            state_id: report.geo_state_id,
            date: report.report_date.to_time(:utc).to_i,
            content: report.content,
            reporter_id: report.reporter_id,
            impact_report: 1,
            languages: language_ids,
            pictures: pictures,
            client: report.client,
            version: report.version,
            updated_at: report.updated_at.to_i
        }
      end
      puts report_data
      render json: {reports: report_data}
    rescue => e
      puts e
      render json: { error: e }
    end
  end

  def create
    full_params = report_params.merge({reporter: logged_in_user})
    report_factory = Report::Factory.new
    if report_factory.create_report(full_params)
      flash['success'] = 'Report Submitted!'
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
    @geo_states = logged_in_user.geo_states
    @zones = Zone.of_states(@geo_states)
    @languages = Language.minorities(@geo_states).order('LOWER(languages.name)')
		@no_language_id = Language.order('id').last.try(:id).to_i + 1
		@languages << Language.new(name:'<no language>', id: @no_language_id)
    # limit reports to the last 6 months to keep things from slowing down too much
    @reports = Report.
        includes(
            :languages,
            :reporter,
            :observers,
            :pictures,
            :topics,
            :geo_state,
            :impact_report => [:progress_markers => :topic]
        ).where(geo_state: @geo_states).
        where('reports.report_date > ?', 6.months.ago).
        order(:report_date => :desc)
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
    actual_user = logged_in_user || current_user
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
      {:pictures_attributes => [:ref, :_destroy, :id, :created_external]},
      {:observers_attributes => [:id, :name]},
      {:impact_report_attributes => [:translation_impact]},
      :status,
      :location,
      :sub_district_id,
      :client,
      :version
    ]
    safe_params.delete :status unless actual_user.admin?
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
