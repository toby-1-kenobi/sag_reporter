class ReportsController < ApplicationController

  helper ColoursHelper

  before_action :require_login

    # Let only permitted users do some things
  before_action only: [:new, :create] do
    redirect_to root_path unless current_user.can_create_report?
  end

  before_action only: [:index, :by_language, :by_topic, :by_reporter] do
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
  	@reports = Report.all
  	@languages = Language.all
  end

  def by_topic
  	@reports = Report.all
  	@topics = Topic.all
  end

  def by_reporter
  	@reports = Report.all
  end

  def archive
  end

  def unarchive
  end

end
