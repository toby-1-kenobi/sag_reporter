class TranslationCode < ActiveRecord::Base
  has_many :translations, dependent: :destroy

  def connected_to
    Ministry.find_by(name: id) ||
        Deliverable.find_by(short_form_id: id) ||
        Deliverable.find_by(plan_form_id: id) ||
        Deliverable.find_by(result_form_id: id)
  end
end
