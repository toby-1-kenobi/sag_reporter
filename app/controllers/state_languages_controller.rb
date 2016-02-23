class StateLanguagesController < ApplicationController

  before_action :require_login

  before_action only: [:outcomes, :get_chart, :get_table, :outcomes_data] do
    redirect_to root_path unless current_user.can_view_outcome_totals?
  end

  def outcomes
    @languages_by_state = Hash.new
    current_user.geo_states.each do |geo_state|
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

    table_data = @language.outcome_table_data()

    if table_data
      table_head = "<thead><tr><th></th>"
      table_data["content"].values.first.keys.each do |cell|
        table_head += "<th>#{cell}</th>"
      end
      table_head += "</tr></thead>"

      table_body = "<tbody>"
      table_data["content"].each do |row_title, row|
        table_body += "<tr><th>#{row_title}</th>"
        row.values.each do |cell|
          table_body += "<td>#{cell}</td>"
        end
        table_body += "</tr>"
      end
      table_body += "<tr><th>Totals</th>"
      table_data["Totals"].values.each do |cell|
        table_body += "<td>#{cell}</td>"
      end
      table_body += "</tr></tbody>"

      @table_content = "<table>#{table_head} #{table_body}</table>"
    else
      @table_content = nil
    end
        
    respond_to do |format|
      format.js
    end
  end

  def outcomes_data
    @state_language = StateLanguage.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = OutcomesTablePdf.new(@state_language)
        send_data pdf.render, filename: "#{@state_language.language_name}_outcomes.pdf", type: 'application/pdf'
      end
    end
  end

  def overview
    @zones = Zone.includes(:geo_states => {:state_languages => :language}).where('state_languages.project' => true)
    @progress_marker_usage = LanguageProgress.with_updates.group(:state_language_id).count
    @progress_marker_count = ProgressMarker.count
  end

end
