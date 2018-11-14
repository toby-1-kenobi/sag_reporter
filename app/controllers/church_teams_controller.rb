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
        deliverable.ministry_outputs.where(church_ministry: church_min).where('month >= ?', 6.months.ago.strftime("%Y-%m")).each do |mo|
          @outputs[church_min.id][deliverable.id][mo.month] ||= {}
          @outputs[church_min.id][deliverable.id][mo.month][mo.actual] = [mo.id, mo.value, mo.comment]
        end
      end
    end
    respond_to :js
  end

end
