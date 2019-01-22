class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Access sessions helper from application controllers.
  include SessionsHelper

  # localisation
  before_action :set_locale

  def set_locale
    if logged_in?
      begin
        I18n.locale = logged_in_user.locale
      rescue I18n::InvalidLocaleData
        Rails.logger.warn('locale error - setting to default')
        I18n.locale = I18n.default_locale
      end
    else
      I18n.locale = I18n.default_locale
    end
  end

  # Let Paper Trail record the user making changes
  def user_for_paper_trail
    logged_in? ? logged_in_user.id : 'Public user'
  end
  before_action :set_paper_trail_whodunnit

  private

    def combine_colour(params)
      unless params[:colour] == "black" or params[:colour] == "white"
        if params[:colour_darkness].to_i > 0
      	  params[:colour] << " darken-" << params[:colour_darkness]
        elsif params[:colour_darkness].to_i < 0
      	  params[:colour] << " lighten-" << params[:colour_darkness].slice(1..-1)
        end
      end
      params.except!(:colour_darkness)
    end

    def record_not_found
      flash["error"] = "We tried to fetch a record that doesn't exist."
      redirect_to root_path
    end

end
