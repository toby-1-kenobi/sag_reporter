class TalliesController < ApplicationController

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_tally?
  end
  
  before_action only: [:index, :show] do
    redirect_to root_path unless logged_in_user.can_view_all_tallies?
  end
  
  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.can_edit_tally?
  end

  before_action :set_tally, only: [:show, :edit, :update]

  def index
    @tallies = Tally.all
  end

  def show
    @updates_by_language = @tally.tally_updates.group_by(&:language)
    @graph_data = graph_data
  end

  def new
    @tally = Tally.new
    @minority_languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
    @topics = Topic.all
  end

  def edit
    @minority_languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
    @topics = Topic.all
  end

  def create
    @tally = Tally.new(tally_params)

    respond_to do |format|
      if @tally.save
        if params['tally']['languages']
          params['tally']['languages'].each do |lang_id, value|
            @tally.languages << Language.find_by_id(lang_id.to_i)
          end
        end
        format.html do
          flash["success"] = "Tally #{@tally.name} created!"
          redirect_to @tally
        end
        format.json { render :show, status: :created, location: @tally }
      else
        format.html do
          @minority_languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
          @topics = Topic.all
          render :new
        end
        format.json { render json: @tally.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @tally.update(tally_params)
        @tally.languages.clear
        if params['tally']['languages']
          params['tally']['languages'].each do |lang_id, value|
            @tally.languages << Language.find_by_id(lang_id.to_i)
          end
        end
        format.html do
          flash["success"] = "Tally #{@tally.name} Updated!"
          redirect_to @tally
        end
        format.json { render :show, status: :ok, location: @tally }
      else
        format.html do
          @minority_languages = Language.minorities(logged_in_user.geo_states).order("LOWER(languages.name)")
          @topics = Topic.all
          render :edit
        end
        format.json { render json: @tally.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tally
      @tally = Tally.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tally_params
      params.require(:tally).permit(:name, :description, :topic_id)
    end

    # Collect data for graphs
    # a hash with language names for keys and values are ActiveRecord sets
    # of tally_updates associated with that language and the present tally
    def graph_data
      data = Hash.new
      Language.minorities(logged_in_user.geo_states).each do |language|
        data[language.name] = @tally.tally_updates.includes(:language).where("languages_tallies.language_id" => language.id)
      end
      return data
    end
end
