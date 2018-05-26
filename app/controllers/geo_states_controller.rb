class GeoStatesController < ApplicationController
  include ReportFilter

  before_action :require_login
  before_action :find_state, except: [:get_autocomplete_items]
  before_action :check_privaleges, only: [:show, :bulk_assess, :bulk_progress_update, :reports]

  autocomplete :district, :name, full: true

  def show
    @flms = FinishLineMarker.order(:number)
    @pending_flm_edits_flp_ids = Edit.pending.where(model_klass_name: 'FinishLineProgress', attribute_name: 'status').pluck :record_id
    @flm_filters = params[:filter].present? ? Language.parse_filter_param(params[:filter]) : Language.use_default_filters
    @tab = params[:tab]
    @filters = {since: 3.month.ago.strftime('%d %B, %Y'), until: Date.today.strftime('%d %B, %Y')}
  end

  def load_flm_summary
    @partial_locals = {}
    @partial_locals[:geo_state] = GeoState.find params[:id]
    @partial_locals[:languages] = @partial_locals[:geo_state].languages.includes(finish_line_progresses: :finish_line_marker).where('state_languages.primary = true').uniq
    @flms = FinishLineMarker.dashboard_visible.order(:number)
    respond_to do |format|
      format.js { render 'languages/load_flm_summary' }
    end
  end

  def load_flt_summary
    @partial_locals = {}
    geo_state = GeoState.find params[:id]
    @partial_locals[:state_languages] = geo_state.state_languages.in_project
    respond_to do |format|
      format.js { render 'languages/load_flt_summary' }
    end
  end

  def load_language_flm_table
    geo_state = GeoState.find params[:id]
    @flms = FinishLineMarker.order(:number)
    @flm_filters = params[:filter].present? ? Language.parse_filter_param(params[:filter]) : Language.use_default_filters
    @pending_flm_edits_flp_ids = Edit.pending.where(model_klass_name: 'FinishLineProgress', attribute_name: 'status').pluck :record_id
    @languages = geo_state.languages.includes({geo_states: :zone}, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user)
    respond_to do |format|
      format.js { render 'languages/load_language_flm_table' }
    end
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:geo_state_id => params[:geo_state_id])
  end

  def get_totals_chart
    respond_to do |format|
      format.js
    end
  end

  def get_outcome_area_chart
    @outcome_area = Topic.find(params[:topic_id])
    respond_to do |format|
      format.js
    end
  end

  def get_combined_languages_chart
    respond_to do |format|
      format.js
    end
  end

  def bulk_assess
    @markers = ProgressMarker.active.order(:number)
  end

  def bulk_progress_update
    date = params[:assessment_date].split('-')
    # get only the values for languages where the switch is on
    level_data = params['bulk-input'].select do |k, v|
      params['language-switch'].keys.include? k
    end
    levels_set = parse_bulk_assess(date.first, date.second, level_data)
    flash['success'] = "Set #{levels_set} transformation progress levels for #{@geo_state.name}"
    redirect_to select_to_assess_path
  end

  def reports
    # if no since date is provided assume 3 months
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    params[:until] ||= Date.today.strftime('%d %B, %Y')
    @filters = report_filter_params
    reports = Report.states(@geo_state).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)
    respond_to do |format|
      format.js { render 'reports/update_collection' }
    end
  end

  private

  def find_state
    @geo_state = GeoState.find(params[:id])
  end

  def check_privaleges
    @geo_state ||= GeoState.find(params[:id])
    redirect_to zones_path unless logged_in_user.national? or @geo_state.users.include?(logged_in_user)
  end

  # bulk input is a hash where the keys are the ids of StateLanguage objects and the values are hashes
  # the inner hashes have progress marker ids as keys and the progress levels as values.
  # everything goes in as a string
  # progress levels may be left blank (empty string) in which case skip them
  # return the total number of levels set
  def parse_bulk_assess(year, month, bulk_input)
    levels_set = 0
    bulk_input.each do |state_language_id, levels|
      levels.select{ |k, v| v.present? }.each do |pm_id, progress|
        lp = LanguageProgress.find_or_create_by(state_language_id: state_language_id, progress_marker_id: pm_id)
        init_count = lp.progress_updates.count
        lp.progress_updates.create(progress: progress, user: logged_in_user, year: year, month: month)
        levels_set += (lp.progress_updates.count - init_count)
      end
    end
    levels_set
  end

end