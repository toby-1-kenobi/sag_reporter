class Deliverable < ActiveRecord::Base

  has_paper_trail

  enum calculation_method: {
      most_recent: 0,
      sum_of_all: 1
  }

  enum reporter: {
      church_team: 0,
      facilitator: 1,
      supervisor: 2,
      auto: 3,
      disabled: 4,
      translation_progress: 6
  }

  belongs_to :ministry
  belongs_to :short_form, class_name: 'TranslationCode', dependent: :destroy
  belongs_to :plan_form, class_name: 'TranslationCode', dependent: :destroy
  belongs_to :result_form, class_name: 'TranslationCode', dependent: :destroy
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :aggregate_ministry_outputs, dependent: :restrict_with_exception
  has_many :quarterly_targets, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :number, presence: true, uniqueness: { scope: :ministry }
  validates :funder_interest, inclusion: [true, false]
  before_create :create_translation_codes

  # Method for reading and writing all translation values (e.g. short_form_en = "?" or plan_form_value)
  # it has to be a combination of the translation connection name and the locale or "value", if the actual I18n locale shall be used
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

  scope :active, -> { where.not(reporter: 4) }

  def translation_key
    "#{ministry.code.upcase}#{sprintf('%02d', number)}"
  end

  def old_short_form
    I18n.t("deliverables.short_form.#{translation_key}")
  end

  scope :with_values, -> do
    translation_code_names = [:short_form_id, :plan_form_id, :result_form_id]
    translation_code_ids = select(translation_code_names).map do |t|
      translation_code_names.map {|name| t.send(name)}
    end.flatten
    @@translations = Translation.where(translation_code_id: translation_code_ids)
    self
  end

  private

  def translations
    @@translations ||= []
    all_translation_code_ids = [short_form_id, plan_form_id, result_form_id]
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
    self.short_form ||= TranslationCode.create
    self.plan_form ||= TranslationCode.create
    self.result_form ||= TranslationCode.create
  end
end
