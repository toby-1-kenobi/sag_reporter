class ProjectLanguagesController < ApplicationController

  def update
    @project_language = ProjectLanguage.find params[:id]
    @project_language.update_attributes(project_language_params)
    respond_to :js
  end

  private

  def project_language_params
    params.require(:project_language).permit(
        :churches_reported,
        :people_in_churches,
        :followup_contact
    )
  end

end
