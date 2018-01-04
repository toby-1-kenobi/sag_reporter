class StateLanguagesController < ApplicationController

  before_action :require_login

  # before_action only: [:outcomes, :get_chart, :get_table, :outcomes_data] do
  #   redirect_to root_path unless logged_in_user.national?
  # end

  def outcomes
    @outcome_areas = Topic.all
    @languages_by_state = Hash.new
    accessible_states = logged_in_user.national? ? GeoState.all.order(:name) : logged_in_user.geo_states
    accessible_states.each do |geo_state|
      @languages_by_state[geo_state] = geo_state.state_languages.includes(:language).in_project.to_a.sort!
    end
  end

  def get_chart
    @outcome_areas = Topic.all
    @language = StateLanguage.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def get_table
    @language = StateLanguage.find(params[:id])

    table_data = @language.outcome_table_data(logged_in_user)

    if table_data
      table_head = '<thead><tr><th></th>'
      table_data['content'].values.first.keys.each do |cell|
        table_head += "<th>#{cell}</th>"
      end
      table_head += '</tr></thead>'

      table_body = '<tbody>'
      table_data['content'].each do |row_title, row|
        table_body += "<tr><th>#{row_title}</th>"
        row.values.each do |cell|
          table_body += "<td>#{cell.round}</td>"
        end
        table_body += '</tr>'
      end
      table_body += '<tr><th>Overall score</th>'
      table_data['Totals'].values.each do |cell|
        table_body += "<td>#{cell.round}</td>"
      end
      table_body += '</tr></tbody>'

      @table_content = "<table>#{table_head} #{table_body}</table>"
    else
      @table_content = nil
    end
        
    respond_to do |format|
      format.js
    end
  end

  def show_outcomes_progress
    @state_language = StateLanguage.find(params[:id])
    @language_progresses_by_pm_id = Hash.new
    @state_language.language_progresses.includes(:progress_updates).find_each do |lp|
      @language_progresses_by_pm_id[lp.progress_marker_id] = lp
    end
    @progress_markers_by_oa_and_weight = ProgressMarker.by_outcome_area_and_weight  
    respond_to do |format|
      format.js
    end
  end

  def outcomes_data
    @state_language = StateLanguage.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = OutcomesTablePdf.new(@state_language, logged_in_user)
        send_data pdf.render, filename: "#{@state_language.language_name}_outcomes.pdf", type: 'application/pdf'
      end
    end
  end

  def overview
    @zones = Zone.includes(:geo_states => {:state_languages => :language}).where('state_languages.project' => true)
    @progress_marker_usage = LanguageProgress.with_updates.joins(:progress_marker).where('progress_markers.status' => 0).group(:state_language_id).uniq.count
    @progress_marker_count = ProgressMarker.active.count
    @pm_status_by_state = Hash.new
    @zones.each do |zone|
      zone.geo_states.each do |geo_state|
        @pm_status_by_state[geo_state] = { none: 0, part: 0, full: 0 }
        geo_state.state_languages.each do |sl|
          usage = @progress_marker_usage[sl.id] || 0
          if usage == 0
            @pm_status_by_state[geo_state][:none] += 1
          elsif usage == @progress_marker_count
            @pm_status_by_state[geo_state][:full] += 1
          else
            @pm_status_by_state[geo_state][:part] += 1
          end
        end
      end
    end
  end

  def transformation
    @outcome_area_colours = Hash.new
    Topic.find_each{ |oa| @outcome_area_colours[oa.name] = oa.colour }
    # Get the earliest in which outcome scores have ben entered
    @start_year = ProgressUpdate.order(:year).first.year
    collect_transformation_data
  end

  def transformation_spreadsheet
    @outcome_areas = Topic.all.pluck :name
    collect_transformation_data
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"transformation.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
      end
    end
  end


  private

  def collect_transformation_data
    # Use dates from parameters or 6 months ago and this month
    params[:year_a] ||= 6.months.ago.year
    params[:month_a] ||= 6.months.ago.month
    date_a = Date.new params[:year_a].to_i, params[:month_a].to_i
    params[:year_b] ||= Date.today.year
    params[:month_b] ||= Date.today.month
    date_b = Date.new params[:year_b].to_i, params[:month_b].to_i
    # for each project language get the aggregated data for both dates
    @transformations = Hash.new
    # join progress updates to only include languages that have had baseline set.
    StateLanguage.in_project.joins(:progress_updates).includes(:language, {geo_state: :zone}, {:language_progresses =>[{:progress_marker => :topic}, :progress_updates]}).uniq.find_each do |state_language|
      @transformations[state_language] = state_language.transformation(logged_in_user, date_a, date_b)
    end
  end

end
