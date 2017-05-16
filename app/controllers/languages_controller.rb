class LanguagesController < ApplicationController
  
  helper ColoursHelper

  before_action :require_login

  # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_create_language?
  end

  # can edit a language if the language is in one of the user's states, or if the user is national
  before_action only: [:edit, :update] do
    redirect_to root_path unless logged_in_user.national? or Language.user_limited(logged_in_user).pluck(:id).include?(params[:id].to_i)
  end

  def index
  	@languages = Language.includes(:family, { geo_states: :zone }).order(:name)
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
            :engaged_organisations,
            :translating_organisations,
            :mt_resources,
            {:state_languages => {:geo_state => :zone}}
        ).
        find(params[:id])
    @all_orgs = Organisation.all.order(:name)
    @user_pending_edits = Edit.pending.where(model_klass_name: 'Language', record_id: @language.id)
    @user_pending_fl_edits = Edit.pending.where(model_klass_name: 'FinishLineProgress')
    unless logged_in_user.curates_for?(@language)
      logger.debug "limiting edits"
      @user_pending_edits = @user_pending_edits.where(user: logged_in_user)
      @user_pending_fl_edits = @user_pending_fl_edits.where(user: logged_in_user)
    end
    @user_pending_fl_edits = @user_pending_fl_edits.to_a.select{ |edit| FinishLineProgress.find(edit.record_id).language == @language }
    # if the user is national or the language is in at least one of the user's member states then the user can edit it
    @editable = (logged_in_user.national? or Language.user_limited(logged_in_user).include?(@language))
    # attributes with pending edits should be visually distinct in the form
    @pending_attributes = @user_pending_edits.pluck :attribute_name
  end

  def show_details
    @language = Language.
        includes(
            :language_names,
            :dialects,
            :pop_source,
            :family,
            :engaged_organisations,
            :translating_organisations,
            :mt_resources,
            {:state_languages => {:geo_state => :zone}}
        ).
        find(params[:id])
    @all_orgs = Organisation.all.order(:name)
    @user_pending_edits = Edit.pending.where(model_klass_name: 'Language', record_id: @language.id)
    @user_pending_fl_edits = Edit.pending.where(model_klass_name: 'FinishLineProgress')
    unless logged_in_user.curates_for?(@language)
      logger.debug "limiting edits"
      @user_pending_edits = @user_pending_edits.where(user: logged_in_user)
      @user_pending_fl_edits = @user_pending_fl_edits.where(user: logged_in_user)
    end
    @user_pending_fl_edits = @user_pending_fl_edits.to_a.select{ |edit| FinishLineProgress.find(edit.record_id).language == @language }
    # get the latest impact report to show on the language details page
    @impact_report = @language.reports.where.not(impact_report: nil).order(:report_date).last
    # if the user is national or the language is in at least one of the user's member states then the user can edit it
    @editable = (logged_in_user.national? or Language.user_limited(logged_in_user).include?(@language))
    # attributes with pending edits should be visually distinct in the form
    @pending_attributes = @user_pending_edits.pluck :attribute_name
  end

  # match a search query against language names
  def search
    query = params['q']
    if query.present?
      # for single character search, just get languages that start with the character
      # otherwise search anywhere in the name
      # also downcase the query string for case insensitive search
      if query.length == 1
        query = "#{query.downcase}%"
      else
        query = "%#{query.downcase}%"
      end
      @languages = Language.where('lower(name) LIKE ?', query)
      respond_to do |format|
        format.js
      end
    else
      head :no_content
    end
  end

  def get_chart
    @outcome_areas = Topic.all
    @state_language = StateLanguage.find(params[:id])
    respond_to do |format|
      format.js
    end
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
    language = Language.find(params[:id])
    @org = Organisation.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'engaged_organisations',
        old_value: Edit.addition_code,
        new_value: params[:org],
        status: :pending_single_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_engaged_org
    language = Language.find(params[:id])
    org = language.engaged_organisations.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'engaged_organisations',
        old_value: org.id.to_s,
        new_value: Edit.removal_code,
        status: :pending_single_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def add_translating_org
    language = Language.find(params[:id])
    @org = Organisation.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'translating_organisations',
        old_value: Edit.addition_code,
        new_value: params[:org],
        status: :pending_double_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_translating_org
    language = Language.find(params[:id])
    org = language.translating_organisations.find(params[:org])
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: language.id,
        attribute_name: 'translating_organisations',
        old_value: org.id.to_s,
        new_value: Edit.removal_code,
        status: :pending_double_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def set_finish_line_progress
    language = Language.find(params[:id])
    marker = FinishLineMarker.find_by_number(params[:marker])
    progress = FinishLineProgress.find_or_create_by(language: language, finish_line_marker: marker)
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'FinishLineProgress',
        record_id: progress.id,
        attribute_name: 'status',
        old_value: progress.status,
        new_value: params[:progress],
        status: :pending_double_approval,
        relationship: false
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    respond_to do |format|
      format.js
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
