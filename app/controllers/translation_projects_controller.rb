class TranslationProjectsController < ApplicationController

  def update
    @translation_project = TranslationProject.find(params[:id])
    @translation_project.update_attributes(translation_project_params)
    respond_to :js
  end

  def add_distribution_method
    @translation_project = TranslationProject.find(params[:id])
    @dm_id = params[:dist_method]
    @translation_project.distribution_method_ids += [@dm_id]
    respond_to :js
  end

  def remove_distribution_method
    @translation_project = TranslationProject.find(params[:id])
    @dm_id = params[:dist_method]
    @translation_project.distribution_methods.delete(DistributionMethod.find @dm_id)
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
