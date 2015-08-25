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
    @topics = Topic.all
    @languages = Language.minorities(current_user.geo_state)
  end

  def assess_progress
    @outcome_area = Topic.find(params[:topic_id])
    @progress_markers_by_weight = ProgressMarker.where(topic: @outcome_area).group_by { |pm| pm.weight }
    @language = Language.find(params[:language_id])
    @reports_by_progress_marker = ImpactReport.where(geo_state: current_user.geo_state).joins(:progress_marker, :languages).where("progress_markers.topic_id" => @outcome_area, "languages.id" => @language).select{ |ir| ir.report_date >= 1.year.ago }.group_by{ |ir| ir.progress_marker_id }
  end

  def update_progress
    outcome_area = Topic.find(params[:topic_id])
    language = Language.find(params[:language_id])
    # We're only updating progress markers where the marker has been selected as done
    # so filter the hash before looping
    params[:progress_marker].select{ |pm, l| params[:marker_complete][pm] }.each do |marker, level|
      progress_marker = ProgressMarker.find(marker)
      language_progress = LanguageProgress.find_or_create_by(language: language, progress_marker: progress_marker)
      ProgressUpdate.create(language_progress: language_progress, progress: level, user: current_user)
      flash.now['success'] = "Progress Markers updated for #{outcome_area.name}."
    end
    @topics = Topic.all
    @languages = Language.minorities(current_user.geo_state)
    render 'assess_progress_select'
  end

  def outcomes
    @languages = Language.minorities(current_user.geo_state)
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

end
