class ReportsController < ApplicationController

  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless current_user.can_create_report?
  end

  before_action only: [:index] do
    redirect_to root_path unless current_user.can_view_all_reports?
  end

  before_action only: [:edit, :update] do
    redirect_to root_path unless current_user.can_edit_report?
  end

  before_action only: [:archive, :unarchive] do
    redirect_to root_path unless current_user.can_archive_report?
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def index
  end

  def by_language
  end

  def by_topic
  end

  def archive
  end

  def unarchive
  end

end
