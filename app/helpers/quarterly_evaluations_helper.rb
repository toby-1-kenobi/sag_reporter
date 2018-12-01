module QuarterlyEvaluationsHelper

  # a user can edit a quarterly evaluation if they are the project manager
  # or if they are a stream supervisor in the project for that stream
  # or an app admin
  def can_edit(quarterly_evaluation, user)
    user.admin? or
    quarterly_evaluation.project.supervisors.where(project_supervisors: { role: 'management' }).include?(user) or
        quarterly_evaluation.project.stream_supervisors.where(project_streams: { ministry: @quarterly_evaluation.ministry }).include?(user)
  end

end
