class TopicsController < ApplicationController

  helper ColoursHelper
  
  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_topic?
  end

  before_action only: [:index] do
    redirect_to root_path unless logged_in_user.can_view_all_topics?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.can_edit_topic?
  end

  before_action only: [:assess_progress_select, :assess_progress, :update_progress] do
    redirect_to root_path unless logged_in_user.can_evaluate_progress?
  end

  before_action only: [:assess_progress_select, :assess_progress] do
    set_date_range
  end

  def new
  	@topic = Topic.new
  	@colour_columns = 3
  end

  def index
  	@topics = Topic.all
  end

  def show
  	@topic = Topic.find(params[:id])
  end

  def edit
  	@topic = Topic.find(params[:id])
  	@colour_columns = 3
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(combine_colour(topic_params))
      flash["success"] = "Topic updated"
      redirect_to @topic
    else
      render 'edit'
    end
  end

  def create
    @topic = Topic.new(combine_colour(topic_params))
    if @topic.save
      flash["success"] = "New topic added!"
      redirect_to @topic
    else
      render 'new'
    end
  end

  def assess_progress_select
    @geo_states = logged_in_user.geo_states
  end

  def assess_progress
    #TODO: pass only state_language id, instead of language and geo_state
    unless Language.exists?(params[:language_id]) and GeoState.exists?(params[:geo_state_id])
      redirect_to select_to_assess_path
    else
      @language = Language.find(params[:language_id])
      @geo_state = GeoState.find(params[:geo_state_id])
      @state_language = StateLanguage.find_by(language: @language, geo_state: @geo_state)
      if !@state_language
        flash["error"] = "#{@language.name} isn't in #{@geo_state.name}"
        redirect_to select_to_assess_path
      else
        @progress_markers_by_weight = Hash.new
        Topic.all.each do |outcome_area|
          @progress_markers_by_weight[outcome_area] = ProgressMarker.where(topic: outcome_area).group_by { |pm| pm.weight }
        end
        @monthly_reports = @language.tagged_impact_reports_monthly(@geo_state, @from_date, @to_date)
        @yearmonth = params[:yearmonth]
        if @yearmonth == "000000" then @yearmonth = Date.today.strftime("%Y%m") end
        @year = @yearmonth.slice(0,4)
        @month = @yearmonth.slice(4,2)
        @month_date = Date.new(@year.to_i, @month.to_i)
        @existing_updates_this_month = ProgressUpdate.
          joins(:language_progress).
          where(
            year: @year,
            month: @month,
            :language_progresses => {state_language_id: @state_language}
          ).group('language_progresses.progress_marker_id').count
        @reports = ImpactReport.
          includes(:progress_markers, :report => [ :reporter, :languages ]).
          where(
            :reports => {
              status: "active",
              geo_state_id: @geo_state,
              report_date: @month_date..@month_date.end_of_month
            },
            :languages => {id: @language}
          ).order('progress_markers.id')
        @reports_by_pm = Hash.new
        @reports_by_oa = Hash.new
        @reports.each do |report|
          report.progress_markers.each do |pm|
            @reports_by_pm[pm] ||= Set.new
            @reports_by_pm[pm] << report
            @reports_by_oa[pm.topic_id] ||= Set.new
            @reports_by_oa[pm.topic_id] << report
          end
        end
      end
    end
  end 

  def update_progress
    if Language.exists?(params[:language_id]) and GeoState.exists?(params[:geo_state_id])
      language = Language.find(params[:language_id])
      geo_state = GeoState.find(params[:geo_state_id])
      state_language = StateLanguage.find_by(language: language, geo_state: geo_state)
      if state_language
        month = params[:yearmonth]
        year = month.slice!(0,4)
        successful_updates = Array.new
        failed_updates = Hash.new
        # We're only updating progress markers where the marker has been selected as done
        # so filter the hash before looping
        if params[:marker_complete]
          params[:progress_marker].select{ |pm, l| params[:marker_complete][pm] }.each do |marker, level|
            progress_marker = ProgressMarker.find(marker)
            language_progress = LanguageProgress.find_or_create_by(state_language: state_language, progress_marker: progress_marker)
            update = ProgressUpdate.create(language_progress: language_progress, progress: level, user: logged_in_user, year: year, month: month)
            if update.persisted?
              successful_updates << update
            else
              failed_updates[progress_marker.name] = update
            end
          end
        end
        if failed_updates.any?
          fail_msg = "These progress marker levels were NOT updated for #{language.name}: "
          fail_msg.concat failed_updates.keys.join(', ')
          flash['error'] = fail_msg
        elsif successful_updates.any?
          flash['success'] = "#{successful_updates.count} progress marker levels updated for #{language.name}."
        else
          flash['warning'] = "No progress marker levels were updated."
        end
      else
        flash['error'] = "Could not update progress marker levels. #{language.name} isn't in #{geo_state.name}"
      end
    else
      flash['error'] = "No progress marker levels were updated. Invalid language or state"
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
