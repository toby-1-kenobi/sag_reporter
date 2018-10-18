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
