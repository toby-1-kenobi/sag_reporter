class LanguagesController < ApplicationController
  
  helper ColoursHelper
  include ReportFilter

  before_action :require_login

  # can edit a language if the language is in one of the user's states, or if the user is national
  before_action only: [:reports, :show, :show_details, :populations] do
    redirect_to zones_path unless logged_in_user.national? or Language.user_limited(logged_in_user).pluck(:id).include?(params[:id].to_i)
  end

  # only an admin user can set the language champion
  before_action only: [:set_champion] do
    head :forbidden unless logged_in_user.admin?
  end

  autocomplete :user, :name, :full => true

  def show
  	@language = Language.
        includes(
            :pop_source,
            :family,
            :engaged_organisations,
            :translating_organisations,
            :mt_resources,
            {:state_languages => {:geo_state => :zone}}
        ).
        find(params[:id])
    @all_orgs = Organisation.all.order(:name)
    @user_pending_edits = Edit.pending.where(model_klass_name: 'Language', record_id: @language.id)
    @user_pending_fl_edits = Edit.pending.where(model_klass_name: 'FinishLineProgress')
    unless logged_in_user.curates_for?(@language)
      logger.debug "limiting edits"
      @user_pending_edits = @user_pending_edits.where(user: logged_in_user)
      @user_pending_fl_edits = @user_pending_fl_edits.where(user: logged_in_user)
    end
    @user_pending_fl_edits = @user_pending_fl_edits.to_a.select{ |edit| FinishLineProgress.find(edit.record_id).language == @language }
    @editable = true # any user who can see a language can suggest edits TODO: remove this variable
    # attributes with pending edits should be visually distinct in the form
    @pending_attributes = @user_pending_edits.pluck :attribute_name
  end

  def show_details
    @language = Language.
        includes(
            :language_names,
            :dialects,
            :pop_source,
            :family,
            :engaged_organisations,
            :translating_organisations,
            :mt_resources,
            {:state_languages => {:geo_state => :zone}}
        ).
        find(params[:id])
    @all_orgs = Organisation.all.order(:name)
    @user_pending_edits = Edit.pending.where(model_klass_name: 'Language', record_id: @language.id)
    @user_pending_fl_edits = Edit.pending.where(model_klass_name: 'FinishLineProgress')
    unless logged_in_user.curates_for?(@language)
      logger.debug "limiting edits"
      @user_pending_edits = @user_pending_edits.where(user: logged_in_user)
      @user_pending_fl_edits = @user_pending_fl_edits.where(user: logged_in_user)
    end
    @user_pending_fl_edits = @user_pending_fl_edits.to_a.select{ |edit| FinishLineProgress.find(edit.record_id).language == @language }
    # get the latest impact report to show on the language details page
    @impact_report = @language.reports.where.not(impact_report: nil).order(:report_date).last
    @editable = true # any user who can see a language can suggest edits TODO: remove this variable
    # attributes with pending edits should be visually distinct in the form
    @pending_attributes = @user_pending_edits.pluck :attribute_name
    @pending_flm_ids = []
    @user_pending_fl_edits.each do |edit|
      flp = FinishLineProgress.find edit.record_id
      @pending_flm_ids << flp.finish_line_marker_id
    end
    @projects = Project.all
  end

  def reports
    @language = Language.find(params[:id])

    # if no since date is provided assume 3 months
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    params[:until] ||= Date.today.strftime('%d %B, %Y')
    @filters = report_filter_params
    reports = Report.language(@language).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)
    respond_to do |format|
      format.html
      format.js { render 'reports/update_collection' }
    end
  end

  # match a search query against language names
  def search
    query = params['q']
    if query.present?
      # for single character search, just get languages that start with the character
      # otherwise search anywhere in the name
      # also downcase the query string for case insensitive search
      if query.length == 1
        query = "#{query.downcase}%"
      else
        iso_query = query.downcase
        query = "%#{query.downcase}%"
      end
      @languages = Language.where('lower(name) LIKE ? or iso = ?', query, iso_query)
      @states = GeoState.where('lower(name) LIKE ?', query)
      respond_to do |format|
        format.js
      end
    else
      head :no_content
    end
  end

  def get_chart
    @outcome_areas = Topic.all
    @state_language = StateLanguage.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def fetch_jp_data
    @iso = params[:iso]
  end

  def set_champion
    @language = Language.find params[:id]
    @champion = User.find_by_name params[:champion]
    if @champion
      @language.champion = @champion
      @language.save
      respond_to :js
    else
      return head :gone
    end
  end

  def assign_project
    @language = Language.find(params[:id])
    if @language.update_attributes(lang_params)
      respond_to :js
    else
      return head :gone
    end
  end

  def outputs_table
    @language = Language.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = OutputsTablePdf.new(@language, logged_in_user.geo_state)
        send_data pdf.render, filename: "#{@language.name}_outputs.pdf", type: 'application/pdf'
      end
    end
  end

  def outcomes_table
    @geo_state = GeoState.find(params[:geo_state_id])
    @language = Language.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = OutcomesTablePdf.new(Topic.all, @language, @geo_state)
        send_data pdf.render, filename: "#{@language.name}_outcomes.pdf", type: 'application/pdf'
      end
    end
  end

  def add_engaged_org
    language = Language.find(params[:id])
    @org = Organisation.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'engaged_organisations',
        old_value: Edit.addition_code,
        new_value: params[:org],
        status: :pending_single_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_engaged_org
    language = Language.find(params[:id])
    org = language.engaged_organisations.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'engaged_organisations',
        old_value: org.id.to_s,
        new_value: Edit.removal_code,
        status: :pending_single_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def add_translating_org
    language = Language.find(params[:id])
    @org = Organisation.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'translating_organisations',
        old_value: Edit.addition_code,
        new_value: params[:org],
        status: :pending_double_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_translating_org
    language = Language.find(params[:id])
    org = language.translating_organisations.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'translating_organisations',
        old_value: org.id.to_s,
        new_value: Edit.removal_code,
        status: :pending_double_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def set_finish_line_progress
    language = Language.find(params[:id])
    marker = FinishLineMarker.find_by_number(params[:marker])
    progress = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: marker)
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'FinishLineProgress',
        record_id: progress.id,
        attribute_name: 'status',
        old_value: progress.status,
        new_value: params[:progress],
        status: :pending_double_approval,
        relationship: false
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def populations
    @language = Language.find params[:id]
    @pending_pop_edits = Edit.pending.where(model_klass_name: 'Language', attribute_name: 'populations', record_id: @language.id)
  end

  # Export language tab information
  def language_tab_spreadsheet
    case params[:dashboard]
      when 'zone'
        Rails.logger.debug('zone')
        @zone = Zone.find params[:zone_id]
        @languages = Language.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user).where(geo_states: {zone: @zone})
        @head_data = "Zone: #{@zone.name}"
      when 'state'
        Rails.logger.debug('state')
        @geo_state = GeoState.find params[:state_id]
        @languages = @geo_state.languages.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user)
        @head_data = "State: #{@geo_state.name}"
      else
        Rails.logger.debug('nation')
        @languages = Language.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user)
        @head_data = "All India"
    end
    @languages = @languages.order(:name)
    @flms = FinishLineMarker.order(:number)
    @flm_filters = params[:flm_filters].present? ? Language.parse_filter_param(params[:flm_filters]) : Language.use_default_filters
    @pending_flm_edits_flp_ids = Edit.pending.where(model_klass_name: 'FinishLineProgress', attribute_name: 'status').pluck :record_id
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"Language_flm_info.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
      end
    end
  end

  private

  def lang_params
    pop_source = DataSource.find_by_name params[:language][:pop_source]
    params[:language][:pop_source_id] = pop_source.id if pop_source
    family = LanguageFamily.find_by_name params[:language][:family]
    params[:language][:family_id] = family.id if family
    params.require(:language).permit(
        :name,
        :description,
        :lwc, :colour,
        :colour_darkness,
        :interface,
        :iso,
        :family_id,
        :population,
        :pop_source_id,
        :location,
        :number_of_translations,
        :info,
        :translation_info,
        :translation_need,
        :translation_progress,
        :project_id
    )
  end

end
