class ZonesController < ApplicationController
  include ReportFilter

  before_action :require_login
  before_action only: [:nation] do
    redirect_to zones_path unless logged_in_user.national?
  end

  def index
    @zones = Zone.all
  end

  def show
    @zone = Zone.find params[:id]
    redirect_to zones_path unless logged_in_user.national? or logged_in_user.zones.include? @zone
    @languages = Language.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user).where(geo_states: {zone: @zone})
    @flms = FinishLineMarker.order(:number)
    @pending_flm_edits_flp_ids = Edit.pending.where(model_klass_name: 'FinishLineProgress', attribute_name: 'status').pluck :record_id
    @flm_filters = params[:filter].present? ? Language.parse_filter_param(params[:filter]) : Language.use_default_filters
    @geo_states = @zone.geo_states
    @geo_states = @geo_states.where(id: logged_in_user.geo_states) unless logged_in_user.national?
    @filters = {since: 3.month.ago.strftime('%d %B, %Y'), until: Date.today.strftime('%d %B, %Y')}
    @tab = params[:tab]
  end

  def load_flm_summary
    @partial_locals = {}
    # if there is an id parameter we are loading for a specific zone
    if params[:id].present?
      @partial_locals[:zone] = Zone.find params[:id]
      @partial_locals[:languages] = @partial_locals[:zone].languages.includes(:finish_line_progresses).uniq
    else
      # otherwise we are loading for the whole nation
      @partial_locals[:languages] = Language.all
    end
    @flms = FinishLineMarker.dashboard_visible.order(:number)
    respond_to do |format|
      format.js { render 'languages/load_flm_summary' }
    end
  end

  def reports
    # if no since date is provided assume 3 months
    params[:since] ||= 3.months.ago.strftime('%d %B, %Y')
    params[:until] ||= Date.today.strftime('%d %B, %Y')
    @filters = report_filter_params
    zone = Zone.find params[:id]
    states = zone.geo_states
    states = states.where(id: logged_in_user.geo_states) unless logged_in_user.national?
    reports = Report.states(states).includes(:pictures, :languages, :impact_report)
    @reports = Report.filter(reports, @filters).order(report_date: :desc)
    respond_to do |format|
      format.js { render 'reports/update_collection' }
    end
  end

  def nation
    @languages = Language.includes({geo_states: :zone}, :family, {finish_line_progresses: :finish_line_marker}).user_limited(logged_in_user)
    @flms = FinishLineMarker.dashboard_visible.order(:number)
    @pending_flm_edits_flp_ids = Edit.pending.where(model_klass_name: 'FinishLineProgress', attribute_name: 'status').pluck :record_id
    @flm_filters = params[:filter].present? ? Language.parse_filter_param(params[:filter]) : Language.use_default_filters
    @tab = params[:tab]
  end

  def national_outcomes_chart
    respond_to do |format|
      format.js
    end
  end

end
