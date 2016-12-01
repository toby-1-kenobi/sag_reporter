class MtResourcesController < ApplicationController

  before_action :require_login

  before_action only: [:new, :create] do
    redirect_to root_path unless logged_in_user.can_add_resource?
  end

  before_action only: [:language_overview] do
    redirect_to root_path unless logged_in_user.can_view_all_resources?
  end

  def new
  	@resource = MtResource.new
    if params[:language]
      @resource.language = Language.find params[:language]
    end
    @languages = Language.minorities(logged_in_user.geo_states).order('LOWER(languages.name)')
  end

  def language_overview
    @language = Language.find(params[:language_id])
    @resources_by_category = MtResource.where(language: @language).group_by{ |r| r.category }
  end

  def create
    @resource = MtResource.new(resource_params)
    @resource.user = logged_in_user
    if @resource.valid?
      person_params = params.select{ |param| param[/^person__\d+$/] }
      person_params.each do |key, person_name|
        if !person_name.blank?
					if person_name.length > 50
			      flash['error'] = 'Name should include maximal 50 characters'
				      @languages = Language.minorities(logged_in_user.geo_states).order('LOWER(languages.name)')
      				render 'new' and return
					end
          @resource.contributers << Person.find_or_create_by(name: person_name) do |person|
            person.record_creator = logged_in_user
            person.geo_state = @resource.geo_state
          end
        end
      end
			@resource.save
      flash['success'] = 'New resource entered'
      redirect_to language_path(@resource.language)
    else
      @languages = Language.minorities(logged_in_user.geo_states).order('LOWER(languages.name)')
      render 'new'
    end

  end

  private

  def resource_params
    params.require('mt_resource').permit(
      :name,
      :description,
      :cc_share_alike,
      :user_id,
      :language_id,
      :category,
      :geo_state_id,
      :url,
      :how_to_access,
      :status,
      :publish_year
    )
  end

end
