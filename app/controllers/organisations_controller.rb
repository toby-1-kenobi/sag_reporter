class OrganisationsController < ApplicationController

  before_action :require_login

  def index
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find params[:id]
  end

end
