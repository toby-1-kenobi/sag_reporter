class StaticPagesController < ApplicationController

  before_action :require_login, only: [:home]

  def home
  end

  def whatsapp_link
    @supress_header = true
    @supress_footer = true
  end

end
