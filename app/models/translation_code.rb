class TranslationCode < ActiveRecord::Base
  has_many :translations, dependent: :destroy

  def connected_to
    Ministry.find_by(name_id: id) ||
        Deliverable.find_by(short_form_id: id) ||
        Deliverable.find_by(plan_form_id: id) ||
        Deliverable.find_by(result_form_id: id)
  end
  
  def en
    translations.find{|t| t.language_id == 1 }&.content
  end

  def hi
    translations.find{|t| t.language_id == 2 }&.content
  end
  
  def en=(value)
    create_en.update content: value
  end

  def hi=(value)
    create_hi.update content: value
  end

  def create_en
    translations.find{|t| t.language_id == 2 } || Translation.create(translation_code: self, language_id: 1)
  end

  def create_hi
    translations.find{|t| t.language_id == 2 } || Translation.create(translation_code: self, language_id: 2)
  end
end
