class ChurchTeamsController < ApplicationController

  before_action :require_login

  def project_table
    @church_team = ChurchTeam.find params[:id]
    @project = Project.find params[:project_id]
    head :forbidden unless logged_in_user.can_view_project?(@project)
    @outputs = {}
    @church_team.church_ministries.active.each do |church_min|
      @outputs[church_min.id] = {}
      church_min.ministry.deliverables.church_team.each do |deliverable|
        @outputs[church_min.id][deliverable.id] = {}
        deliverable.ministry_outputs.where(church_ministry: church_min, actual: true).where('month >= ?', 6.months.ago.strftime("%Y-%m")).each do |mo|
          @outputs[church_min.id][deliverable.id][mo.month] = [mo.id, mo.value, mo.comment]
        end
      end
    end
    @active_month = 1.month.ago.strftime('%Y-%m')
    respond_to :js
  end

  def quarterly_table
    project = Project.find params[:project_id]
    head :forbidden unless logged_in_user.can_view_project?(project)
    @stream = Ministry.find params[:stream_id]
    @church_min = ChurchMinistry.find_by(church_team_id: params[:id], ministry_id: @stream.id)
    @first_month = params[:first_month]
    last_month = 3.months.since(Date.new(@first_month[0..3].to_i, @first_month[-2..-1].to_i)).strftime('%Y-%m')
    @outputs = {}
    @stream.deliverables.church_team.each do |deliverable|
      @outputs[deliverable.id] = {}
      deliverable.ministry_outputs.where(church_ministry: @church_min, actual: true).where('month >= ?', @first_month).where('month < ?', last_month).each do |mo|
        @outputs[deliverable.id][mo.month] = mo.value
      end
    end
    respond_to :js
  end

  def edit_impact
    @church_min_id = params[:church_min]
    @month = params[:month]
    start_day = Date.strptime(@month, '%Y-%m').beginning_of_month
    end_day = start_day.end_of_month
    church_min = ChurchMinistry.find @church_min_id
    @reports = Report.joins(:report_streams, :languages).where(
        church_team: church_min.church_team,
        geo_state: church_min.church_team.state_language.geo_state,
        languages: { id: church_min.church_team.state_language.language_id },
        report_streams: { ministry_id: church_min.ministry_id }
    ).where('report_date BETWEEN ? AND ?', start_day, end_day).order(:report_date)
    respond_to :js
  end

  def add_bible_verse
    @bible_verse = BiblePassage.parse(params[:bible_ref])
    if @bible_verse
      @bible_verse.church_ministry_id = params[:church_min]
      @bible_verse.month = params[:month]
      if @bible_verse.valid?
        old_verse = BiblePassage.find_by(church_ministry_id: params[:church_min], month: params[:month])
        old_verse&.destroy
        @bible_verse.save
      end
    end
    respond_to :js
  end

  def update_transformation_sign
    @church_min_id = params[:church_min]
    @sign_marker_id = params[:transformation_sign]
    if @sign_marker_id == 'other'
      if params[:text].present?
        @trans_sign = SignOfTransformation.create(
            church_ministry_id: @church_min_id,
            other: params[:text],
            month: params[:month]
        )
      end
    else
      if params[:activate] == 'true'
        SignOfTransformation.create(
            church_ministry_id: @church_min_id,
            marker_id: @sign_marker_id,
            month: params[:month]
        )
      else
        SignOfTransformation.where(
            church_ministry_id: @church_min_id,
            marker_id: @sign_marker_id,
            month: params[:month]
        ).destroy_all
      end
    end
    respond_to :js
  end

  def update_other_transformation_sign
    if params[:sign_id] == 'potential'
      @sign = SignOfTransformation.create(
          church_ministry_id: params[:church_min],
          month: params[:month],
          other: params[:text]
      )
    else
      @sign = SignOfTransformation.find params[:sign_id]
      @sign.update_attributes(other: params[:text])
    end
    respond_to :js
  end

  def remove_other_transformation_sign
    @sign_id = params[:sign_id]
    SignOfTransformation.find(@sign_id).destroy
    respond_to :js
  end

end
