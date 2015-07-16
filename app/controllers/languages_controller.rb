class LanguagesController < ApplicationController
  
  before_action :require_login

  def index
  	@languages = Language.all
  end

  def new
  	@language = Language.new
  end

  def edit
  	@language = Language.find(params[:id])
  end

  def show
  	@language = Language.find(params[:id])
  end

  def update
    @language = Language.find(params[:id])
    if @language.update_attributes(lang_params)
      flash["success"] = "Language updated"
      redirect_to @language
    else
      render 'edit'
    end
  end

  def create
    @language = Language.new(lang_params)
    if @language.save
      flash["success"] = "New language added!"
      redirect_to @language
    else
      render 'new'
    end
  end

    private

    def lang_params
      params.require(:language).permit(:name, :description, :lwc)
    end
  
end
