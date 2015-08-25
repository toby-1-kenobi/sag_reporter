class MtResourcesController < ApplicationController

  before_action :require_login

  def new
  	@resource = MtResource.new
    @languages = Language.minorities
  end

  def language_overview
    @language = Language.find(params[:language_id])
    @resources_by_category = MtResource.where(language: @language).group_by{ |r| r.category }
  end

  def create
    @resource = MtResource.new(resource_params)
    if @resource.save
      @resource.user = current_user
      person_params = params.select{ |param| param[/^person__\d+$/] }
      person_params.each do |key, person_name|
        @resource.contributers << Person.find_or_create_by(name: person_name) unless person_name.empty?
      end
      flash['success'] = "New resource entered"
      redirect_to action: "language_overview", language_id: @resource.language_id
    else
      @languages = Language.minorities
      render new
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
      :category
    )
  end

end
