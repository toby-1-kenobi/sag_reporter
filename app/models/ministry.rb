class Ministry < ActiveRecord::Base

  has_paper_trail

  has_many :deliverables, dependent: :destroy
  has_many :quarterly_targets, through: :deliverables
  has_many :language_streams, dependent: :destroy
  has_many :facilitators, through: :language_streams, class_name: 'User'
  has_many :church_ministries, dependent: :destroy
  has_many :church_teams, through: :church_ministries
  has_many :project_streams, dependent: :destroy
  has_many :projects, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  has_many :report_streams, dependent: :destroy
  has_many :reports, through: :report_streams
  has_many :quarterly_evaluations, dependent: :restrict_with_error
  has_many :sign_of_transformation_markers, dependent: :destroy
  belongs_to :topic
  belongs_to :name, class_name: 'TranslationCode', dependent: :destroy
  belongs_to :short_form, class_name: 'TranslationCode', dependent: :destroy
  before_create :create_translation_codes

  # This is a class method that caches the names
  # so we don't have to hit the db every time we need to look up a name
  def self.stream_name(id, locale)
    Rails.cache.fetch("stream_name_#{id}_#{locale}", expires_in: 2.hours) do
      Ministry.find(id).name.send(locale)
    end
  end

  # Method for reading and writing all translation values (e.g. name_en = "?" or name_value)
  # it has to be a combination of the translation connection name and the actual locale or "value", if the I18n locale shall be used
  # if it can't find a value in a specific language, it takes English, if it exists; doesn't work for not defined locales
  def method_missing(method_id, *args)
    locale = method_id.to_s.split("_").last
    translation_code_name = method_id.to_s.remove "_#{locale}"
    if self.class.reflect_on_association(translation_code_name)&.klass == TranslationCode
      is_assignment = locale.last == "="
      locale.remove! "=" if is_assignment
      locale = I18n.locale if locale == "value"
      possible_locales = {en: 1, hi: 2}
      language_id = possible_locales[locale.to_sym] || super
      translation_code_id = send("#{translation_code_name}_id")
      if is_assignment
        content = args.first
        find_translation(language_id, translation_code_id)&.update(content: content) ||
            create_translation(language_id, translation_code_id, content)
        @translations = nil
      else
        find_translation(language_id, translation_code_id)&.content ||
            find_translation(1, translation_code_id)&.content
      end
    else
      super
    end
  end

  scope :with_values, -> do
    translation_code_names = [:name_id, :short_form_id]
    translation_code_ids = select(translation_code_names).map do |t|
      translation_code_names.map {|name| t.send(name)}
    end.flatten
    @@translations = Translation.where(translation_code_id: translation_code_ids)
    self
  end

  private

  def translations
    @@translations ||= []
    all_translation_code_ids = [name_id, short_form_id]
    unless @@translations.find{|translation| translation.translation_code_id.in? all_translation_code_ids}
      @@translations.push(*Translation.where(translation_code_id: all_translation_code_ids))
    end
    @@translations
  end

  def create_translation(language_id, translation_code_id, content)
    Translation.create(translation_code_id: translation_code_id, language_id: language_id, content: content)
  end

  def find_translation(language_id, translation_code_id)
    translations.find{|translation| translation.language_id == language_id && translation.translation_code_id == translation_code_id}
  end

  def create_translation_codes
    self.name ||= TranslationCode.create
    self.short_form ||= TranslationCode.create
  end
end
