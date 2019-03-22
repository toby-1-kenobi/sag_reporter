class TranslationProjectsController < ApplicationController

  def create
    tp_params = translation_project_params
    if tp_params[:name].blank?
      tp_params[:name] = 'Translation Project'
      i = 1
      # make sure name is unique
      while TranslationProject.exists?(name: tp_params[:name], language_id: tp_params[:language_id])
        tp_params[:name] = "Translation Project #{i}"
        i += 1
      end
    end
    @translation_project = TranslationProject.create(tp_params)
    respond_to :js
  end

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
