class Ministry < ActiveRecord::Base

  has_many :deliverables, dependent: :destroy
  has_many :quarterly_targets, through: :deliverables
  has_many :language_streams, dependent: :destroy
  has_many :facilitators, through: :language_streams, class_name: 'User'
  has_many :church_ministries, dependent: :destroy
  has_many :church_teams, through: :church_ministries
  has_many :project_streams, dependent: :destroy
  has_many :projects, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  belongs_to :topic
  belongs_to :name, class_name: 'TranslationCode', dependent: :delete
  before_create :create_translation_codes
  after_destroy :delete_translation_codes

  scope :with_values, ->{
    joins("LEFT JOIN translations AS translation_en " +
              "ON translation_en.translation_code_id = short_form_id " +
              "AND translation_en.language_id = 1")
        .joins("LEFT JOIN translations AS translation_hi " +
              "ON translation_en.translation_code_id = short_form_id " +
              "AND translation_en.language_id = 2")
        .select("*, translation_en.content AS name_en, translation_hi.content AS name_hi")
  }

  scope :with_values, ->(language_id) {
    joins("LEFT JOIN translations AS translation " +
              "ON translation.translation_code_id = name_id " +
              "AND translation.language_id = #{language_id}")
        .select("*, content AS name_value")
  }

  scope :with_translations, -> { includes(name: [:translations]) }
  
  def old_name
    I18n.t("ministries.names.#{code.upcase}")
  end

  def create_translation_codes
    self.name ||= TranslationCode.create
  end

  def delete_translation_codes
    self.name.delete
  end

end
