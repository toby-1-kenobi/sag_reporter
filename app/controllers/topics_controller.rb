class TopicsController < ApplicationController

  helper ColoursHelper
  
  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:assess_progress_select, :assess_progress] do
    set_date_range
  end

  def assess_progress_select
    @geo_states = logged_in_user.geo_states
  end

  def assess_progress
    @state_language = StateLanguage.find(params[:state_language_id])
    # make sure months is an int and is bigger than 0 otherwise set it to default of 3
    begin
      raise 'months not enough' unless params[:months].to_i > 0
    rescue => e
      Rails.logger.debug(e.message)
      params[:months] = '3'
    end
    if !@state_language
      redirect_to select_to_assess_path
    else
      duration = params[:months].to_i.months
      @progress_markers_by_weight = Hash.new
      Topic.all.order(:number).each do |outcome_area|
        # TODO: Try to do this without hitting the db separately for each outcome area
        @progress_markers_by_weight[outcome_area] = ProgressMarker.active.where(topic: outcome_area).order(weight: :asc, number: :asc).group_by { |pm| pm.weight }
      end
      @reports = @state_language.recent_impact_reports(duration)
      @existing_updates_this_month = ProgressUpdate.
        joins(:language_progress).
        where(
          year: Time.now.year,
          month: Time.now.month,
          :language_progresses => {state_language_id: @state_language}
        ).group('language_progresses.progress_marker_id').count
      @reports_by_pm = Hash.new
      @reports_by_oa = Hash.new
      @reports.each do |report|
        report.progress_markers.active.each do |pm|
          @reports_by_pm[pm] ||= Set.new
          @reports_by_pm[pm] << report
          @reports_by_oa[pm.topic_id] ||= Set.new
          @reports_by_oa[pm.topic_id] << report
        end
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        @latest_progress = Hash.new
        @state_language.language_progresses.each do |lp|
          if lp.progress_updates.any?
            @latest_progress[lp.progress_marker] = lp.progress_updates.order(:year, :month, :created_at).last.progress
          else
            @latest_progress[lp.progress_marker] = nil
          end
        end
        pdf = AssessProgressPdf.new(@state_language, params[:months], logged_in_user, @reports_by_pm, @latest_progress)
        send_data pdf.render, filename: "#{@state_language.language_name}_outcomes.pdf", type: 'application/pdf'
      end
    end
  end 

  def update_progress
    state_language = StateLanguage.find(params[:state_language_id])
    if state_language
      successful_updates = Array.new
      failed_updates = Hash.new
      # We're only updating progress markers where the marker has been selected as done
      # so filter the hash before looping
      if params[:marker_complete]
        params[:progress_marker].select{ |pm, l| params[:marker_complete][pm] }.each do |marker, level|
          progress_marker = ProgressMarker.find(marker)
          language_progress = LanguageProgress.find_or_create_by(state_language: state_language, progress_marker: progress_marker)
          update = ProgressUpdate.create(language_progress: language_progress, progress: level, user: logged_in_user, year: Time.now.year, month: Time.now.month)
          if update.persisted?
            successful_updates << update
          else
            failed_updates[progress_marker.name] = update
          end
        end
      end
      if failed_updates.any?
        fail_msg = "These progress marker levels were NOT updated for #{state_language.language_name}: "
        fail_msg.concat failed_updates.keys.join(', ')
        flash['error'] = fail_msg
      elsif successful_updates.any?
        flash['success'] = "#{successful_updates.count} progress marker levels updated for #{state_language.language_name}."
      else
        flash['warning'] = 'No progress marker levels were updated.'
      end
    else
      flash['error'] = 'Could not update progress marker levels.'
    end
    redirect_to select_to_assess_path
  end

    private

    def topic_params
      params.require(:topic).permit(:name, :description, :colour, :colour_darkness)
    end

    def set_date_range
      @from_date = 1.year.ago.to_date
      @to_date = Date.today
      @month_range = (@from_date..@to_date).select{ |d| d.day == 1 }
    end

end
