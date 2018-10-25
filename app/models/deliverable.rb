class Deliverable < ActiveRecord::Base

  enum calculation_method: {
      most_recent: 0,
      sum_of_all: 1
  }

  enum reporter: {
      church_team: 0,
      facilitator: 1,
      supervisor: 2,
      auto: 3,
      disabled: 4
  }

  belongs_to :ministry
  belongs_to :short_form, class_name: 'TranslationCode', dependent: :destroy
  belongs_to :plan_form, class_name: 'TranslationCode', dependent: :destroy
  belongs_to :result_form, class_name: 'TranslationCode', dependent: :destroy
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :quarterly_targets, dependent: :restrict_with_error
  validates :ministry, presence: true
  validates :number, presence: true, uniqueness: { scope: :ministry }
  before_create :create_translation_codes
  after_destroy :delete_translation_codes
  
  scope :with_locales, ->{
    joins("LEFT JOIN translations AS short_form_translation_en " +
              "ON short_form_translation_en.translation_code_id = short_form_id " +
              "AND short_form_translation_en.language_id = 1")
        .joins("LEFT JOIN translations AS plan_form_translation_en  " +
                   "ON plan_form_translation_en.translation_code_id = plan_form_id " +
                   "AND short_form_translation_en.language_id = 1")
        .joins("LEFT JOIN translations AS result_form_translation_en  " +
                   "ON result_form_translation_en.translation_code_id = result_form_id " +
                   "AND short_form_translation_en.language_id = 1")
        .joins("LEFT JOIN translations AS short_form_translation_hi " +
              "ON short_form_translation_hi.translation_code_id = short_form_id " +
              "AND short_form_translation_hi.language_id = 2")
        .joins("LEFT JOIN translations AS plan_form_translation_hi  " +
                   "ON plan_form_translation_hi.translation_code_id = plan_form_id " +
                   "AND short_form_translation_hi.language_id = 2")
        .joins("LEFT JOIN translations AS result_form_translation_hi  " +
                   "ON result_form_translation_hi.translation_code_id = result_form_id " +
                   "AND short_form_translation_hi.language_id = 2")
        .select("*, short_form_translation_en.content AS short_form_en, " +
                    "plan_form_translation_en.content AS plan_form_en, " +
                    "result_form_translation_en.content AS result_form_en, " +
                    "short_form_translation_hi.content AS short_form_hi, " +
                    "plan_form_translation_hi.content AS plan_form_hi, " +
                    "result_form_translation_hi.content AS result_form_hi")
  }

  scope :with_values, ->(language_id) {
    joins("LEFT JOIN translations AS short_form_translation " +
              "ON short_form_translation.translation_code_id = short_form_id " +
              "AND short_form_translation.language_id = #{language_id}")
        .joins("LEFT JOIN translations AS plan_form_translation  " +
                   "ON plan_form_translation.translation_code_id = plan_form_id " +
                   "AND short_form_translation.language_id = #{language_id}")
        .joins("LEFT JOIN translations AS result_form_translation  " +
                   "ON result_form_translation.translation_code_id = result_form_id " +
                   "AND short_form_translation.language_id = #{language_id}")
        .select("*, short_form_translation.content AS short_form_value, " +
                    "plan_form_translation.content AS plan_form_value, " +
                    "result_form_translation.content AS result_form_value")
  }

  scope :with_translations, -> { includes(short_form: [:translations], plan_form: [:translations], result_form: [:translations]) }

  scope :active, -> { where.not(reporter: 4) }

  def translation_key
    "#{ministry.code.upcase}#{sprintf('%02d', number)}"
  end

  def old_short_form
    I18n.t("deliverables.short_form.#{translation_key}")
  end

  def create_translation_codes
    self.short_form ||= TranslationCode.create
    self.plan_form ||= TranslationCode.create
    self.result_form ||= TranslationCode.create
  end

  def delete_translation_codes
    self.short_form.delete
    self.plan_form.delete
    self.result_form.delete
  end

end
