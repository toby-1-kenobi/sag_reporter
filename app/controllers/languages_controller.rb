class LanguagesController < ApplicationController
  
  helper ColoursHelper

  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_language?
  end

  before_action only: [:index] do
    redirect_to root_path unless logged_in_user.can_view_all_languages?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.can_edit_language?
  end

  def index
  	@languages = Language.includes(:family, { geo_states: :zone }).order('LOWER(languages.name)')
  end

  def overview
    # convert to an array here and manage it in the view
    # this is for lack of scopes in the model for translation status
    @languages = Language.all.to_a
  end

  def new
  	@language = Language.new
  	@colour_columns = 3
  end

  def edit
  	@language = Language.find(params[:id])
  	@colour_columns = 3
  end

  def show
  	@language = Language.
        includes(
            :pop_source,
            :family,
            :cluster,
            :engaged_organisations,
            :translating_organisations,
            :mt_resources,
            {:state_languages => {:geo_state => :zone}}
        ).
        find(params[:id])
    @all_orgs = Organisation.all.order(:name)
  end

  def fetch_jp_data
    @iso = params[:iso]
  end

  def update
    @language = Language.find(params[:id])
    if @language.update_attributes(combine_colour(lang_params))
      flash['success'] = 'Language updated'
      respond_to do |format|
        format.json {
          logger.debug 'update request in json format'
          flash.keep('success')
          render json: {redirect: language_path(@language)}.to_json
        }
        format.html {
          logger.debug 'update request in html format'
          @all_orgs = Organisation.all.order(:name)
          render 'show'
        }
      end
    else
      @colour_columns = 3
      respond_to do |format|
        format.json {
          render json: {errors: @language.errors.full_messages}.to_json
        }
        format.html {
          @all_orgs = Organisation.all.order(:name)
          render 'show'
        }
      end
    end
  end

  def create
    @language = Language.new(combine_colour(lang_params))
    if @language.save
      flash['success'] = 'New language added!'
      redirect_to @language
    else
      render 'new'
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
    success = false
    org = Organisation.find(params[:org])
    if org
      language = Language.find(params[:id])
      language.engaged_organisations << org
      success = language.engaged_organisations.include? org
    end
    respond_to do |format|
      format.json {
        render json: {success: success, orgId: org.id, orgName: org.name_with_abbr}.to_json
      }
    end
  end

  def remove_engaged_org
    success = false
    language = Language.find(params[:id])
    org = language.engaged_organisations.find(params[:org])
    if org
      language.engaged_organisations.delete org
      success = !language.engaged_organisations.include?(org)
    end
    respond_to do |format|
      format.json {
        render json: {success: success}.to_json
      }
    end
  end

  def add_translating_org
    success = false
    org = Organisation.find(params[:org])
    if org
      language = Language.find(params[:id])
      language.translating_organisations << org
      success = language.translating_organisations.include? org
    end
    respond_to do |format|
      format.json {
        render json: {success: success, orgId: org.id, orgName: org.name_with_abbr}.to_json
      }
    end
  end

  def remove_translating_org
    success = false
    language = Language.find(params[:id])
    org = language.translating_organisations.find(params[:org])
    if org
      language.translating_organisations.delete org
      success = !language.translating_organisations.include?(org)
    end
    respond_to do |format|
      format.json {
        render json: {success: success}.to_json
      }
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
        :translation_progress
    )
  end

end
