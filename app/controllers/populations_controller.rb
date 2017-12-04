class PopulationsController < ApplicationController

  before_action :require_login

  def create
    population_attr = population_params
    Rails.logger.debug("population attributes: #{population_attr}")
    lang_id = population_attr.delete('language_id')
    @edit = Edit.new(
        user: logged_in_user,
        model_klass_name: 'Language',
        record_id: lang_id,
        attribute_name: 'populations',
        old_value: Edit.addition_code,
        new_value: population_attr,
        status: :pending_single_approval,
        relationship: true
    )
    if @edit.save
      if @edit.user.national_curator?
        @edit.auto_approved!
        @edit.apply
      end
    end
    @language = Language.find lang_id
    respond_to do |format|
      format.js
    end
  end

  private

  def population_params
    params.require(:population).permit([
        :amount,
        :year,
        :source,
        :international,
        :language_id
    ])
  end

end
