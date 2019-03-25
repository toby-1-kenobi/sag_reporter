class TranslationProjectsController < ApplicationController

  def update
    @translation_project = TranslationProject.find(params[:id])
    @translation_project.update_attributes(translation_project_params)
    respond_to :js
  end

  private

  def translation_project_params
    params.require(:translation_project).
        permit(:name,
               :language_id,
               :office_location,
               :survey_findings,
               :orthography_notes,
               :publisher,
               :copyright
        )
  end

end
