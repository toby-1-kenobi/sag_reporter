class StaticPagesController < ApplicationController
  include UsersHelper
  before_action :require_login, only: [:about]

  def about
    @outcome_areas = Topic.all.order(:number)
  end

  def whatsapp_link
    @supress_header = true
    @supress_footer = true
  end

end
