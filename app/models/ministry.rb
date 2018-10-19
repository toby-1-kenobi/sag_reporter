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
