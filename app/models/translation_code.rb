class TranslationCode < ActiveRecord::Base

  has_many :translations, dependent: :destroy
  has_one :ministry, foreign_key: 'name_id', inverse_of: :name

  def deliverable
    Deliverable.where("short_form_id = ? OR plan_form_id = ? OR result_form_id = ?", id, id, id).first
  end
  
  def connected_entry
    ministry || deliverable
  end

  # Method for reading and writing all translation values (e.g. en = "?" or value)
  # it has to be the locale or "value", if the actual I18n locale shall be used
  # if it can't find a value in a specific language, it takes English, if it exists; doesn't work for not defined locales
  def method_missing(method_id, *args)
    locale = method_id.to_s
    is_assignment = locale.last == "="
    locale.remove! "=" if is_assignment
    locale = I18n.locale if locale == "value"
    possible_locales = {en: 1, hi: 2}
    language_id = possible_locales[locale.to_sym] || super
    if is_assignment
      content = args.first
      translations.find{|t| t.language_id == language_id }&.update(content: content) ||
          Translation.create(translation_code: self, language_id: language_id, content: content)
    else
      translations.find{|t| t.language_id == language_id }&.content ||
          translations.find{|t| t.language_id == 1 }&.content
    end
  end

end
