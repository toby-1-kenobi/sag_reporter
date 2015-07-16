class LanguagesController < ApplicationController
  def index
  	@languages = Language.all
  end

  def new
  end

  def edit
  end

  def show
  	@language = Language.find(params[:id])
  end
end
