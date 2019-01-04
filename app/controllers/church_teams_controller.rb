class ChurchTeamsController < ApplicationController

  before_action :require_login

  def project_table
    @church_team = ChurchTeam.find params[:id]
    @project = Project.find params[:project_id]
    head :forbidden unless logged_in_user.can_view_project?(@project)
    @outputs = {}
    @church_team.church_ministries.each do |church_min|
      @outputs[church_min.id] = {}
      church_min.ministry.deliverables.church_team.each do |deliverable|
        @outputs[church_min.id][deliverable.id] = {}
        deliverable.ministry_outputs.where(church_ministry: church_min, actual: true).where('month >= ?', 6.months.ago.strftime("%Y-%m")).each do |mo|
          @outputs[church_min.id][deliverable.id][mo.month] = [mo.id, mo.value, mo.comment]
        end
      end
    end
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

end
