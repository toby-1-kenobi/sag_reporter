class TopicsController < ApplicationController

  helper ColoursHelper
  
  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless current_user.can_create_topic?
  end

  before_action only: [:index] do
    redirect_to root_path unless current_user.can_view_all_topics?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless current_user.can_edit_topic?
  end

  before_action only: [:assess_progress_select, :assess_progress, :update_progress] do
    redirect_to root_path unless current_user.can_evaluate_progress?
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
    @geo_states = current_user.geo_states
  end

  def assess_progress
    @progress_markers_by_weight = Hash.new
    Topic.all.each do |outcome_area|
      @progress_markers_by_weight[outcome_area] = ProgressMarker.where(topic: outcome_area).group_by { |pm| pm.weight }
    end
    @language = Language.find(params[:language_id])
    @geo_state = GeoState.find(params[:geo_state_id])
    @reports = ImpactReport.active.where(geo_state: @geo_state).joins(:languages).where("languages.id" => @language, 'impact_reports.report_date' => @from_date..@to_date).uniq
    #TODO: check that the language belongs to the geo_state and return to assess_progress_select if its not
  end 

  def update_progress
    outcome_area = Topic.find(params[:topic_id])
    language = Language.find(params[:language_id])
    year = Date.current.year
    if params[:date][:month].to_i > Date.current.month
      year -= 1
    end
    # We're only updating progress markers where the marker has been selected as done
    # so filter the hash before looping
    params[:progress_marker].select{ |pm, l| params[:marker_complete][pm] }.each do |marker, level|
      progress_marker = ProgressMarker.find(marker)
      language_progress = LanguageProgress.find_or_create_by(language: language, progress_marker: progress_marker)
      ProgressUpdate.create(language_progress: language_progress, progress: level, user: current_user, geo_state_id: params[:geo_state_id], year: year, month: params[:date][:month])
      flash.now['success'] = "Progress Markers updated for #{language.name} #{outcome_area.name}."
    end
    @topics = Topic.all
    render 'assess_progress_select'
  end

  def outcomes
    @languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
  end

  def get_chart
    @language = Language.find(params[:language_id])
    respond_to do |format|
      format.js
    end
  end

    private

    def topic_params
      params.require(:topic).permit(:name, :description, :colour, :colour_darkness)
    end

    def set_date_range
      @from_date = 1.year.ago.to_date
      @to_date = Date.today
    end

end
